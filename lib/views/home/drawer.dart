import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:attendify/theme/attendify_theme.dart';

import 'package:attendify/components/drawer_footer.dart';
import 'package:attendify/components/drawer_list_grade_specialty.dart';
import 'package:attendify/components/user_account_drawer_header.dart';
import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/attendify_teacher.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/models/user_of_attendify.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';

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

  void _selectAdminTab(BuildContext context, int tabIndex) {
    final tabController = DefaultTabController.maybeOf(context);
    Navigator.pop(context);
    tabController?.animateTo(tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      UserAccountDrawerHeader(
                        username: userType == 'admin'
                            ? admin?.userName ?? 'Admin'
                            : userType == 'teacher'
                                ? teacher?.userName ?? 'Teacher'
                                : student?.userName ?? 'Student',
                        email: authService.currentUsr?.email ??
                            'user@hns-re2sd.dz',
                        profileURL: userType == 'admin'
                            ? admin?.photoURL ?? ''
                            : userType == 'teacher'
                                ? teacher?.photoURL ?? ''
                                : student?.photoURL ?? '',
                      ),

                      // ── Role-specific items ──────────────────────────────────
                      if (userType == 'student')
                        DrawerListGradeSpecialty(user: student)
                      else if (userType == 'teacher')
                        ListTile(
                          leading: const Icon(
                            Icons.add_chart_rounded,
                            color: AttendifyPalette.primary,
                          ),
                          title: const Text('Select modules'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AttendifyPalette.mutedText,
                          ),
                          onTap: () {
                            Navigator.pop(context);
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
                        )
                      else ...[
                        // Admin items
                        const Padding(
                          padding: EdgeInsets.fromLTRB(
                              AttendifySpacing.lg,
                              AttendifySpacing.lg,
                              AttendifySpacing.lg,
                              AttendifySpacing.sm),
                          child: Text(
                            'ADMINISTRATION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AttendifyPalette.mutedText,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.dashboard_rounded,
                            color: AttendifyPalette.primary,
                          ),
                          title: const Text('Overview'),
                          subtitle: const Text('Stats & quick actions'),
                          onTap: () => _selectAdminTab(context, 0),
                        ),
                        const Divider(
                            indent: AttendifySpacing.lg,
                            endIndent: AttendifySpacing.lg),
                        ListTile(
                          leading: const Icon(
                            Icons.menu_book_rounded,
                            color: AttendifyPalette.primary,
                          ),
                          title: const Text('Modules'),
                          subtitle: const Text('Browse & filter modules'),
                          onTap: () => _selectAdminTab(context, 1),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.co_present_rounded,
                            color: AttendifyPalette.primary,
                          ),
                          title: const Text('Teachers'),
                          subtitle: const Text('Faculty & whitelisted emails'),
                          onTap: () => _selectAdminTab(context, 2),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.school_rounded,
                            color: AttendifyPalette.primary,
                          ),
                          title: const Text('Students'),
                          subtitle: const Text('Enrolled accounts'),
                          onTap: () => _selectAdminTab(context, 3),
                        ),
                      ],
                    ],
                  ),
                ),
                const DrawerFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
