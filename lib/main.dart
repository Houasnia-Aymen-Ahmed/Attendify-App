import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:attendify/firebase_options.dart';
import 'package:attendify/responsive/responsive_layout_screen.dart';
import 'package:attendify/routes/routes.dart';
import 'package:attendify/services/notification_service.dart';
import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/views/wrappers/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService().initialize();
  runApp(
    const ProviderScope(
      child: Attendify(),
    ),
  );
}

class Attendify extends StatelessWidget {
  const Attendify({super.key});

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
