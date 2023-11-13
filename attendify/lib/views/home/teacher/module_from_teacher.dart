import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/loading.dart';
import 'package:attendify/views/home/teacher/presence_table.dart';
import 'package:flutter/material.dart';

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
      stream: _databaseService
          .getStudentsList(widget.module.students.keys.toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No students found.');
        } else {
          List<Student> students = snapshot.data!;
          return StreamBuilder<Module>(
            stream: _databaseService.getModuleStream(widget.module.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text(
                    "in module_View:48\n Error: ${snapshot.error.toString()}");
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
