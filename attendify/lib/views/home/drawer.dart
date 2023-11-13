import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/attendify_student.dart';
import '../../models/attendify_teacher.dart';
import '../../models/module_model.dart';
import '../../services/auth.dart';
import '../../services/databases.dart';
import '../../shared/constants.dart';

class BuildDrawer extends StatelessWidget {
  final AuthService authService;
  final DatabaseService databaseService;
  final String userType;
  final Student? student;
  final Teacher? teacher;
  final List<Module>? modules;
  const BuildDrawer({
    super.key,
    required this.authService,
    required this.databaseService,
    required this.userType,
    this.student,
    this.teacher,
    this.modules,
  });

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
                  username: student?.userName ?? "UserName",
                  email: authService.currentUsr?.email ?? "user@hns-re2sd.dz",
                ),
                if (userType == "student")
                  ...drawerList(student)
                else
                  ListTile(
                    title: const Text("Add a module"),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {                      
                      Navigator.pushNamed(
                        context,
                        '/selectModule',
                        arguments: {
                          'modules': modules,
                          'teacher': teacher,
                          'databaseService': databaseService,
                          'authService': authService,
                        },
                      );
                    },
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
