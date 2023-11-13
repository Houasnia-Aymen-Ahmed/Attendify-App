import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/loading.dart';
import 'package:attendify/views/home/body.dart';
import 'package:attendify/views/home/drawer.dart';
import 'package:flutter/material.dart';

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
        if (snapshot.hasError) {
          return Text(
            'An error occurred while loading data: ${snapshot.error}',
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (!snapshot.hasData) {
          return const Text("No student data found");
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
