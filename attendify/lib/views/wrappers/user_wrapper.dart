import 'package:attendify/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/attendify_student.dart';
import '../../models/attendify_teacher.dart';
import '../../models/user.dart';
import '../../models/user_of_attendify.dart';
import '../../shared/error_pages.dart';
import '../../shared/loading.dart';
import '../admin/dashboard.dart';
import '../home/student/student_view.dart';
import '../home/teacher/teacher_view.dart';

class UserWrapper extends ConsumerWidget {
  final UserHandler user;
  const UserWrapper({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final databaseService = ref.watch(databaseServiceProvider);

    return StreamBuilder<AttendifyUser>(
      stream: databaseService.getUserDataStream(user.uid!),
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
          AttendifyUser userData = snapshot.data!;
          if (userData.userType == "admin") {
            return Dashboard(
              admin: userData,
            );
          } else if (userData.userType == 'teacher') {
            Teacher teacher = Teacher(
              userName: userData.userName,
              userType: userData.userType,
              uid: userData.uid,
              email: userData.email,
              photoURL: userData.photoURL,
            );
            return TeacherView(
              teacher: teacher,
            );
          } else {
            Student student = Student(
              userName: userData.userName,
              userType: userData.userType,
              uid: userData.uid,
              email: userData.email,
              photoURL: userData.photoURL,
            );
            return StudentView(
              student: student,
            );
          }
        }
      },
    );
  }
}
