import 'package:flutter/material.dart';

import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/error_pages.dart';
import 'package:attendify/shared/loading.dart';
import 'package:attendify/views/home/body.dart';

class StudentView extends StatelessWidget {
  final Student student;
  final DatabaseService databaseService;
  final AuthService authService;

  const StudentView({
    super.key,
    required this.student,
    required this.databaseService,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Student>(
      stream: databaseService.getStudentDataStream(authService.currentUsr!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (snapshot.hasError) {
          return ErrorPages(
            title: 'Server Error',
            message: snapshot.error.toString(),
          );
        } else if (!snapshot.hasData) {
          return const ErrorPages(
            title: 'Error 404: Not Found',
            message: 'No student data found',
          );
        }

        return BuildBody(
          student: snapshot.data!,
          databaseService: databaseService,
          authService: authService,
        );
      },
    );
  }
}
