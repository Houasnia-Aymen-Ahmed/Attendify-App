import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuildDrawer extends StatelessWidget {
  final Student student;
  const BuildDrawer({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.blue[100],
      elevation: 10,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                userAccountDrawerHeader(
                  username: student.userName,
                  email: AuthService().currentUsr?.email,
                ),
                ListTile(
                  title: Text(capitalizeFirst(student.userName)),
                  subtitle: const Text("username"),
                ),
                ListTile(
                  title: Text(capitalizeFirst(student.grade)),
                  subtitle: const Text("Grade"),
                ),
                ListTile(
                  title: Text(capitalizeFirst(student.speciality)),
                  subtitle: const Text("Speciality"),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Houasnia-Aymen-Ahmed\n© 2023-${DateTime.now().year} All rights reserved",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
