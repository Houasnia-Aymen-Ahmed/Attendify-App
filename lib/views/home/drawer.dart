import 'dart:ui';

import 'package:flutter/material.dart';

import '../../components/drawer_footer.dart';
import '../../components/drawer_list_grade_specialty.dart';
import '../../components/user_account_drawer_header.dart';
import '../../models/attendify_student.dart';
import '../../models/attendify_teacher.dart';
import '../../models/module_model.dart';
import '../../models/user_of_attendify.dart';
import '../../services/auth.dart';
import '../../services/databases.dart';

class BuildDrawer extends StatelessWidget {
  final AuthService authService;
  final DatabaseService databaseService;
  final String userType;
  final AttendifyUser? admin;
  final Student? student;
  final Teacher? teacher;
  final List<Module>? modules;
  const BuildDrawer({
    super.key,
    required this.authService,
    required this.databaseService,
    required this.userType,
    this.admin,
    this.student,
    this.teacher,
    this.modules,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Drawer(
          backgroundColor: Colors.blue[100],
          elevation: 10,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    UserAccountDrawerHeader(
                      username: userType == "admin"
                          ? admin?.userName ?? "admin"
                          : userType == "teacher"
                              ? teacher?.userName ?? "Teacher"
                              : student?.userName ?? "Student",
                      email:
                          authService.currentUsr?.email ?? "user@hns-re2sd.dz",
                      profileURL: userType == "admin"
                          ? admin?.photoURL ?? ""
                          : userType == "teacher"
                              ? teacher?.photoURL ?? ""
                              : student?.photoURL ?? "",
                    ),
                    if (userType == "student")
                      DrawerListGradeSpecialty(user: student)
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
              const DrawerFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
