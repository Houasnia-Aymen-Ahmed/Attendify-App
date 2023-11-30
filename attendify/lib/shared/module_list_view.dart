import 'package:attendify/services/databases.dart';
import 'package:flutter/material.dart';

import '../models/attendify_student.dart';
import '../models/attendify_teacher.dart';
import '../models/module_model.dart';

class ModuleListView extends StatefulWidget {
  final List<Module> modules;
  final DatabaseService databaseService;
  final String userType;
  final Student? student;
  final Teacher? teacher;

  const ModuleListView({
    super.key,
    required this.modules,
    required this.databaseService,
    required this.userType,
    this.student,
    this.teacher,
  });

  @override
  State<ModuleListView> createState() => _ModuleListViewState();
}

class _ModuleListViewState extends State<ModuleListView> {
  dynamic gotoModule(BuildContext context, Module module) {
    if (widget.userType == "student") {
      if (module.isActive) {
        return () => Navigator.pushNamed(
              context,
              '/moduleViewFromStudent',
              arguments: {
                'module': module,
                'student': widget.student,
                'databaseService': widget.databaseService,
              },
            );
      } else {
        return null;
      }
    } else {
      return () => Navigator.pushNamed(
            context,
            '/moduleViewFromTeacher',
            arguments: {
              'module': module,
              'databaseService': widget.databaseService,
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.modules.length,
      itemBuilder: (BuildContext context, int index) {
        print("in module list view: ${widget.modules[index].isActive}");
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Card(
            color: Colors.blue[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ListTile(
              enabled: widget.userType == "student"
                  ? widget.modules[index].isActive
                  : true,
              leading: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Icon(
                  Icons.circle_rounded,
                  color: widget.modules[index].isActive //For Cursor-GPT: this color suppose to change based on isActive on real-time, but it doesn't change until i hit hot-reload
                      ? Colors.green[900]
                      : Colors.red,
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
              title: Text(widget.modules[index].name),
              onTap: gotoModule(context, widget.modules[index]),
            ),
          ),
        );
      },
    );
  }
}
