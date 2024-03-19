import 'package:flutter/material.dart';

import '../../models/attendify_student.dart';
import '../../models/attendify_teacher.dart';
import '../../models/module_model.dart';
import '../../models/user.dart';
import '../../models/user_of_attendify.dart';
import '../../services/auth.dart';
import '../../services/databases.dart';
import '../../shared/error_pages.dart';
import '../../shared/loading.dart';
import '../admin/dashboard.dart';
import '../home/student/student_view.dart';
import '../home/teacher/teacher_view.dart';

class UserWrapper extends StatelessWidget {
  final UserHandler user;
  final DatabaseService databaseService;
  final AuthService authService;
  const UserWrapper({
    super.key,
    required this.user,
    required this.databaseService,
    required this.authService,
  });

  Future<Map<String, dynamic>> getData() async {
    List<Module> modules = await databaseService.getAllModules();
    List<Student> students = await databaseService.getAllStudents();
    Map<String, dynamic> teachersAndEmails =
        await databaseService.getAllTeachersAndEmails();
    return {
      "modules": modules,
      "students": students,
      "teachersAndEmails": teachersAndEmails,
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AttendifyUser>(
      stream: databaseService.getUserDataStream(authService.currentUsr!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (snapshot.hasError) {
          return ErrorPages(
            title: "Server Error",
            message: snapshot.error.toString(),
          );
        } else if (!snapshot.hasData) {
          return const ErrorPages(
            title: "Error 404: Not Found",
            message: "No user data available",
          );
        } else {
          AttendifyUser user = snapshot.data!;
          if (user.userType == "admin") {
            return FutureBuilder<Map<String, dynamic>>(
                future: getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loading();
                  } else if (snapshot.hasError) {
                    return ErrorPages(
                      title: "Server Error",
                      message: snapshot.error.toString(),
                    );
                  } else if (!snapshot.hasData) {
                    return const ErrorPages(
                      title: "Error 404: Not Found",
                      message: "No data available",
                    );
                  } else {
                    Map<String, dynamic> data = snapshot.data!;
                    return Dashboard(
                      admin: user,
                      databaseService: databaseService,
                      authService: authService,
                      data: data,
                    );
                  }
                });
          } else if (user.userType == 'teacher') {
            Teacher teacher = Teacher(
              userName: user.userName,
              userType: user.userType,
              uid: user.uid,
              email: user.email,
              photoURL: user.photoURL,
            );
            return TeacherView(
              teacher: teacher,
              databaseService: databaseService,
              authService: authService,
            );
          } else {
            Student student = Student(
              userName: user.userName,
              userType: user.userType,
              uid: user.uid,
              email: user.email,
              photoURL: user.photoURL,
            );
            return StudentView(
              student: student,
              databaseService: databaseService,
              authService: authService,
            );
          }
        }
      },
    );
  }
}
