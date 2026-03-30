import 'package:flutter/material.dart';

import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/error_pages.dart';
import 'package:attendify/shared/loading.dart';
import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/theme/attendify_ui.dart';
import 'package:attendify/views/home/teacher/presence_table.dart';

class ModuleViewFromTeacher extends StatelessWidget {
  final Module module;
  final DatabaseService databaseService;

  const ModuleViewFromTeacher({
    super.key,
    required this.module,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Student>>(
      stream: databaseService.getStudentsList(module.students.keys.toList()),
      builder: (context, studentsSnapshot) {
        if (studentsSnapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (studentsSnapshot.hasError) {
          return ErrorPages(
            title: 'Server Error',
            message: studentsSnapshot.error.toString(),
          );
        } else if (!studentsSnapshot.hasData || studentsSnapshot.data!.isEmpty) {
          return const ErrorPages(
            title: 'Error 404: Not Found',
            message: 'There are no students for this module',
          );
        }

        final students = studentsSnapshot.data!;

        return StreamBuilder<Module>(
          stream: databaseService.getModuleStream(module.uid),
          builder: (context, moduleSnapshot) {
            if (moduleSnapshot.connectionState == ConnectionState.waiting) {
              return const Loading();
            } else if (moduleSnapshot.hasError) {
              return ErrorPages(
                title: 'Server Error',
                message: moduleSnapshot.error.toString(),
              );
            } else if (!moduleSnapshot.hasData) {
              return const Loading();
            }

            final refreshedModule = moduleSnapshot.data!;

            return Scaffold(
              body: AttendifyScreen(
                leading: const Icon(
                  Icons.menu_book_rounded,
                  color: AttendifyPalette.primary,
                ),
                title: refreshedModule.name,
                subtitle:
                    '${refreshedModule.grade} year • ${refreshedModule.speciality}',
                actions: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ],
                child: PresenceTable(
                  students: students,
                  module: refreshedModule,
                  databaseService: databaseService,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
