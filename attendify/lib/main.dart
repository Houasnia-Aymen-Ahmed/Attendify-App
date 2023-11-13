import 'package:attendify/firebase_options.dart';
import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/models/user.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/views/home/teacher/select_module.dart';
import 'package:attendify/views/home/student/student_view.dart';
import 'package:attendify/views/home/teacher/module_from_teacher.dart';
import 'package:attendify/views/wrappers/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/attendify_teacher.dart';
import 'views/home/student/module_from_student.dart';
import 'views/home/teacher/teacher_view.dart';

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
          '/studentView': (context) {
            var args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            var student = args['student'] as Student;
            var databaseService = args['databaseService'] as DatabaseService;
            var authService = args['authService'] as AuthService;
            return StudentView(
              student: student,
              databaseService: databaseService,
              authService: authService,
            );
          },
          '/teacherView': (context) {
            var args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            var teacher = args['teacher'] as Teacher;
            var databaseService = args['databaseService'] as DatabaseService;
            var authService = args['authService'] as AuthService;
            return TeacherView(
              teacher: teacher,
              databaseService: databaseService,
              authService: authService,
            );
          },
          '/moduleViewFromTeacher': (context) {
            var args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            var module = args['module'] as Module;
            return ModuleViewFromTeacher(
              module: module,
            );
          },
          '/moduleViewFromStudent': (context) {
            var args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            var module = args['module'] as Module;
            var student = args['student'] as Student;
            return ModuleViewFromStudent(
              module: module,
              student: student,
            );
          },
          '/selectModule': (context) {
            var args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            var modules = args['modules'] as List<Module>;
            var teacher = args['teacher'] as Teacher;
            var databaseService = args['databaseService'] as DatabaseService;
            var authService = args['authService'] as AuthService;
            return SelectModule(
              modules: modules,
              teacher: teacher,
              databaseService: databaseService,
              authService: authService,
            );
          },
        },
      ),
    );
  }
}
