import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/attendify_teacher.dart';
import 'package:attendify/models/user.dart';
import 'package:attendify/models/user_of_attendify.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/loading.dart';
import 'package:attendify/views/home/student/student_view.dart';
import 'package:attendify/views/home/teacher/teacher_view.dart';
import 'package:flutter/material.dart';

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
          return Text(
            'An error occurred while loading data: ${snapshot.error}',
          );
        } else if (!snapshot.hasData) {
          return const Text('No user data available');
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
