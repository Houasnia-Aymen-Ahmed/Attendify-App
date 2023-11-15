import 'package:flutter/material.dart';

import 'signin.dart';
import 'student_register.dart';
import 'teacher_register.dart';

class Authenticate extends StatefulWidget {
  final String userType;
  const Authenticate({super.key, required this.userType});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  void toggleView() => setState(() => showSignIn = !showSignIn);

  @override
  Widget build(BuildContext context) {
    if (showSignIn == true) {
      if (widget.userType == "teacher") {
        return TeacherRegister(toggleView: toggleView);
      } else {
        return StudentRegister(toggleView: toggleView);
      }
    } else {
      return SignIn(
        toggleView: toggleView,
      );
    }
  }
}
