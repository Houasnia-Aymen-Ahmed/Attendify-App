import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/loading.dart';
import 'package:attendify/views/home/body.dart';
import 'package:attendify/views/home/drawer.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final Student student;
  const Home({super.key, required this.student});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseService _dataService = DatabaseService();
  final AuthService _auth = AuthService();
  String userUid = "";
  @override
  void initState() {
    super.initState();
    userUid = _auth.currentUsr!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Student>(
      stream: _dataService.getStudentDataStream(userUid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
              'An error occurred while loading data: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Loading();
        } else {
          final Student student = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text("Attendify"),
              backgroundColor: Colors.blue[200],
              actions: [
                IconButton(
                  onPressed: () {
                    AuthService().logout(context);
                  },
                  icon: const Icon(Icons.logout_rounded),
                )
              ],
            ),
            drawer: BuildDrawer(student: student),
            body: BuildBody(student: student),
          );
        }
      },
    );
  }
}
