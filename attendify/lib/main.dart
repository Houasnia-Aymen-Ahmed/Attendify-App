import 'package:attendify/firebase_options.dart';
import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/models/user.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/views/home/home.dart';
import 'package:attendify/views/home/module_view.dart';
import 'package:attendify/views/type_wrapper.dart';
import 'package:attendify/views/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        home: const Wrapper(),
        routes: {
          '/home': (context) {
            var args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            var student = args['student'] as Student;
            return Home(
              student: student,
            );
          },
          '/typewrapper': (context) => const TypeWrapper(),
          '/moduleView': (context) {
            var args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            var module = args['module'] as Module;
            return ModuleView(
              module: module,
            );
          },
        },
      ),
    );
  }
}
