import 'package:flutter/material.dart';

import '../../../models/attendify_student.dart';
import '../../../models/module_model.dart';
import '../../../services/databases.dart';
import '../../../shared/error_pages.dart';
import '../../../shared/loading.dart';
import 'presence_table.dart';

class ModuleViewFromTeacher extends StatefulWidget {
  final Module module;
  final DatabaseService databaseService;
  const ModuleViewFromTeacher({
    super.key,
    required this.module,
    required this.databaseService,
  });

  @override
  State<ModuleViewFromTeacher> createState() => _ModuleViewFromTeacherState();
}

class _ModuleViewFromTeacherState extends State<ModuleViewFromTeacher> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Student>>(
      stream: widget.databaseService.getStudentsList(
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
            stream: widget.databaseService.getModuleStream(widget.module.uid),
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
                print(" in module from teacher : ${module.isActive}");
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
                    databaseService: widget.databaseService,
                    
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
