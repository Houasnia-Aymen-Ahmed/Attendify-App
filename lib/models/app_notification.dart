import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic> payload;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.payload = const {},
  });

  bool get isRead => readAt != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt == null ? null : Timestamp.fromDate(readAt!),
      'payload': payload,
    };
  }

  factory AppNotification.fromJson(
    Map<String, dynamic> json, {
    String? id,
  }) {
    return AppNotification(
      id: id ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: _asDateTime(json['createdAt']) ?? DateTime.now(),
      readAt: _asDateTime(json['readAt']),
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const {}),
    );
  }
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
