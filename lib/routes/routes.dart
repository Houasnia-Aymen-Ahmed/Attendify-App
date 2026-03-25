import 'package:flutter/material.dart';

import '../models/attendify_student.dart';
import '../models/module_model.dart';
import '../services/auth.dart';
import '../services/databases.dart';
import '../models/attendify_teacher.dart';
import '../views/home/student/module_from_student.dart';
import '../views/home/student/student_view.dart';
import '../views/home/teacher/teacher_view.dart';
import '../views/home/teacher/module_from_teacher.dart';
import '../views/home/teacher/select_module.dart';

enum ViewType {
  student,
  teacher,
  moduleFromTeacher,
  moduleFromStudent,
  selectModule,
}

Map<String, WidgetBuilder> generateRoutes() {
  return {
    '/studentView': (context) => buildView(context, ViewType.student),
    '/teacherView': (context) => buildView(context, ViewType.teacher),
    '/moduleViewFromTeacher': (context) =>
        buildView(context, ViewType.moduleFromTeacher),
    '/moduleViewFromStudent': (context) =>
        buildView(context, ViewType.moduleFromStudent),
    '/selectModule': (context) => buildView(context, ViewType.selectModule),
  };
}

Widget buildView(BuildContext context, ViewType viewType) {
  var args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  var databaseService = args['databaseService'] as DatabaseService;
  var authService = args['authService'] as AuthService? ?? AuthService();

  switch (viewType) {
    case ViewType.student:
      var student = args['student'] as Student;
      return StudentView(
        student: student,
        databaseService: databaseService,
        authService: authService,
      );
    case ViewType.teacher:
      var teacher = args['teacher'] as Teacher;
      return TeacherView(
        teacher: teacher,
        databaseService: databaseService,
        authService: authService,
      );
    case ViewType.moduleFromTeacher:
      var module = args['module'] as Module;
      return ModuleViewFromTeacher(
        module: module,
        databaseService: databaseService,
      );
    case ViewType.moduleFromStudent:
      var module = args['module'] as Module;
      var student = args['student'] as Student;
      return ModuleViewFromStudent(
        module: module,
        student: student,
        databaseService: databaseService,
      );
    case ViewType.selectModule:
      var modules = args['modules'] as List<Module>;
      var teacher = args['teacher'] as Teacher;
      return SelectModule(
        modules: modules,
        teacher: teacher,
        databaseService: databaseService,
        authService: authService,
      );
  }
}
