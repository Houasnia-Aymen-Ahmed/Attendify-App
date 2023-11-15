import 'package:flutter/material.dart';

import '../../models/attendify_student.dart';
import '../../models/attendify_teacher.dart';
import '../../models/user.dart';
import '../../models/user_of_attendify.dart';
import '../../services/auth.dart';
import '../../services/databases.dart';
import '../../shared/error_pages.dart';
import '../../shared/loading.dart';
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
          if (user.userType == 'teacher') {
            Teacher teacher = Teacher(
              userName: user.userName,
              userType: user.userType,
              token: user.token,
              uid: user.uid,
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
              token: user.token,
              uid: user.uid,
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
