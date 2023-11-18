import 'package:flutter/material.dart';

import '../../../models/attendify_student.dart';
import '../../../models/module_model.dart';
import '../../../services/databases.dart';
import '../../../shared/error_pages.dart';
import '../../../shared/loading.dart';
import 'presence_table.dart';

class ModuleViewFromTeacher extends StatefulWidget {
  final Module module;
  const ModuleViewFromTeacher({super.key, required this.module});

  @override
  State<ModuleViewFromTeacher> createState() => _ModuleViewFromTeacherState();
}

class _ModuleViewFromTeacherState extends State<ModuleViewFromTeacher> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Student>>(
      stream: _databaseService.getStudentsList(
        widget.module.students.keys.toList(),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (snapshot.hasError) {
          return ErrorPages(
            title: "Server Error",
            message: snapshot.error.toString(),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const ErrorPages(
            title: "Error 404: Not Found",
            message: "There are no students for this module",
          );
        } else {
          List<Student> students = snapshot.data!;
          return StreamBuilder<Module>(
            stream: _databaseService.getModuleStream(widget.module.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorPages(
                  title: "Server Error",
                  message: snapshot.error.toString(),
                );
              } else if (!snapshot.hasData) {
                return const Loading();
              } else {
                Module module = snapshot.data!;
                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      module.name,
                      style: const TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.blue[200],
                  ),
                  body: PresenceTable(
                    students: students,
                    module: module,
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
