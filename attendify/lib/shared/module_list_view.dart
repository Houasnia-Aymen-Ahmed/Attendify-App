import 'package:attendify/views/home/student/module_from_student.dart';
import 'package:attendify/views/home/teacher/module_from_teacher.dart';
import 'package:flutter/material.dart';

import '../models/attendify_student.dart';
import '../models/attendify_teacher.dart';
import '../models/module_model.dart';

class ModuleListView extends StatelessWidget {
  final List<Module> modules;
  final String userType;
  final Student? student;
  final Teacher? teacher;

  const ModuleListView({
    super.key,
    required this.modules,
    required this.userType,
    this.student,
    this.teacher,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: modules.length,
      itemBuilder: (BuildContext context, int index) {
        final module = modules[index];
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Card(
            color: Colors.blue[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ListTile(
              enabled: userType == "student" ? module.isActive : true,
              leading: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Icon(
                  Icons.circle_rounded,
                  color: module.isActive ? Colors.green[900] : Colors.red,
                ),
              ),
              trailing: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              splashColor: Colors.blue[300],
              contentPadding: const EdgeInsets.all(5.0),
              title: Text(module.name),
              onTap: () {
                if (userType == "student") {
                  if (module.isActive) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModuleViewFromStudent(
                          module: module,
                          student: student!,
                        ),
                      ),
                    );
                  }
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModuleViewFromTeacher(
                        module: module,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
