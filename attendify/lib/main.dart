import 'package:attendify/responsive/responsive_layout_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/attendify_student.dart';
import 'models/attendify_teacher.dart';
import 'models/module_model.dart';
import 'models/user.dart';
import 'services/auth.dart';
import 'services/databases.dart';
import 'views/home/student/module_from_student.dart';
import 'views/home/student/student_view.dart';
import 'views/home/teacher/module_from_teacher.dart';
import 'views/home/teacher/select_module.dart';
import 'views/home/teacher/teacher_view.dart';
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
            var databaseService = args['databaseService'] as DatabaseService;
            return ModuleViewFromTeacher(
              module: module,
              databaseService: databaseService,
            );
          },
          '/moduleViewFromStudent': (context) {
            var args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            var module = args['module'] as Module;
            var student = args['student'] as Student;
            var databaseService = args['databaseService'] as DatabaseService;
            return ModuleViewFromStudent(
              module: module,
              student: student,
              databaseService: databaseService,
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
