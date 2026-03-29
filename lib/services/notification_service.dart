import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:attendify/firebase_options.dart';
import 'package:attendify/models/app_notification.dart';

// Must be a top-level function — called by the OS when the app is in background/terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Background handling logic goes here when needed.
}

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Live session, attendance, and waiver updates.',
  importance: Importance.high,
);

class NotificationService {
  final FirebaseFirestore _firestore;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  NotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notificationsCollection =>
      _firestore.collection('AppNotifications');

  CollectionReference<Map<String, dynamic>> get _deviceCollection =>
      _firestore.collection('NotificationDevices');

  // ── Initialisation ─────────────────────────────────────────────────────────

  /// Call once from main() before runApp.
  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    // Local notifications (used for foreground FCM messages)
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (_) {},
    );

    final androidImpl = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(_channel);

    // Show notifications while app is in the foreground
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    _initialized = true;
  }

  /// Call after sign-in to register this device's FCM token.
  /// Stores the token in Firestore under NotificationDevices/{userId}.
  Future<void> registerDeviceToken(String userId) async {
    if (kIsWeb) return;

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // iOS requires an APNs token before FCM token is available
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final apns = await FirebaseMessaging.instance.getAPNSToken();
      if (apns == null) return;
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await _saveToken(userId: userId, token: token);

    // Keep the stored token fresh if it rotates
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (refreshed) => _saveToken(userId: userId, token: refreshed),
    );
  }

  // ── In-app notifications (Firestore-based) ─────────────────────────────────

  Stream<List<AppNotification>> streamNotifications(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => AppNotification.fromJson(d.data(), id: d.id))
            .toList());
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).set(
      {'readAt': Timestamp.fromDate(DateTime.now())},
      SetOptions(merge: true),
    );
  }

  // ── Local notifications ────────────────────────────────────────────────────

  /// Manually show a local notification (e.g. triggered by a Firestore event).
  Future<void> showLocalNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (kIsWeb) return;
    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  // ── Private ────────────────────────────────────────────────────────────────

  Future<void> _saveToken({
    required String userId,
    required String token,
  }) async {
    await _deviceCollection.doc(userId).set(
      {
        'userId': userId,
        'token': token,
        'platform': defaultTargetPlatform.name,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final n = message.notification;
    final title = n?.title ?? message.data['title'] as String?;
    final body = n?.body ?? message.data['body'] as String?;
    if (title == null && body == null) return;

    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
}
