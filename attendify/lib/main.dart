import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/user.dart';
import 'responsive/responsive_layout_screen.dart';
import 'services/auth.dart';
import 'routes/routes.dart';
import 'views/wrappers/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const Attentdify(),
  );
}

class Attentdify extends StatelessWidget {
  const Attentdify({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserHandler?>.value(
      value: AuthService().user,
      initialData: null,
      catchError: (context, error) {
        return null;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Attendify",
        theme: ThemeData.light(),
        home: const ResponsiveLayout(mobileScreenLayout: Wrapper()),
        routes: generateRoutes(),
      ),
    );
  }
}
