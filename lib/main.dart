import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'responsive/responsive_layout_screen.dart';
import 'views/wrappers/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      title: "Attendify",
      theme: ThemeData.light(),
      home: const ResponsiveLayout(mobileScreenLayout: Wrapper()),
    );
  }
}
