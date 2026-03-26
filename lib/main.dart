import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;

import 'firebase_options.dart';
import 'responsive/responsive_layout_screen.dart';
import 'routes/routes.dart';
import 'services/notification_service.dart';
import 'theme/attendify_theme.dart';
import 'views/wrappers/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService().initialize();
  runApp(
    const ProviderScope(
      child: Attentdify(),
    ),
  );
}

class Attentdify extends StatelessWidget {
  const Attentdify({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendify',
      theme: AttendifyTheme.build(),
      home: const ResponsiveLayout(mobileScreenLayout: Wrapper()),
      routes: generateRoutes(),
    );
  }
}
