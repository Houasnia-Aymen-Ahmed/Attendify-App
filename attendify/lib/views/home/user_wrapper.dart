import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/attendify_teacher.dart';
import 'package:attendify/models/user.dart';
import 'package:attendify/models/user_of_attendify.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/loading.dart';
import 'package:attendify/views/home/home.dart';
import 'package:attendify/views/home/teacher_view.dart';
import 'package:flutter/material.dart';

class UserWrapper extends StatefulWidget {
  final UserHandler user;
  const UserWrapper({super.key, required this.user});

  @override
  State<UserWrapper> createState() => _UserWrapperState();
}

class _UserWrapperState extends State<UserWrapper> {
  late final DatabaseService _dataService;
  late final AuthService _auth;

  @override
  void initState() {
    super.initState();
    _dataService = DatabaseService();
    _auth = AuthService();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AttendifyUser>(
        stream: _dataService.getUserDataStream(_auth.currentUsr!.uid),
        builder: (context, snapshot) {
          return _buildContent(snapshot);
        });
  }

  Widget _buildContent(AsyncSnapshot<dynamic> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Loading();
    } else if (snapshot.hasError) {
      return Text('An error occurred while loading data: ${snapshot.error}');
    } else if (!snapshot.hasData) {
      return const Text('No user data available');
    } else {
      final AttendifyUser user = snapshot.data!;
      if (user.userType == 'teacher') {
        Teacher teacher = Teacher(
          userName: user.userName,
          userType: user.userType,
          token: user.token,
          uid: user.uid,
        );
        return TeacherView(teacher: teacher);
      } else {
        Student student = Student(
          userName: user.userName,
          userType: user.userType,
          token: user.token,
          uid: user.uid,
        );
        return Home(student: student);
      }
    }
  }
}
