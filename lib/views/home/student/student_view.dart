import 'package:flutter/material.dart';

import '../../../models/attendify_student.dart';
import '../../../services/auth.dart';
import '../../../services/databases.dart';
import '../../../shared/error_pages.dart';
import '../../../shared/loading.dart';
import '../body.dart';
import '../drawer.dart';

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
      stream: databaseService.getStudentDataStream(
        authService.currentUsr!.uid,
      ),
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
            message: "No student data found",
          );
        } else {
          final Student student = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text("Attendify"),
              backgroundColor: Colors.blue[200],
              actions: [
                IconButton(
                  onPressed: () {
                    authService.logout(context);
                  },
                  icon: const Icon(Icons.logout_rounded),
                )
              ],
            ),
            drawer: BuildDrawer(
              student: student,
              authService: authService,
              databaseService: databaseService,
              userType: "student",
            ),
            body: BuildBody(
              student: student,
              databaseService: databaseService,
              authService: authService,
            ),
          );
        }
      },
    );
  }
}
