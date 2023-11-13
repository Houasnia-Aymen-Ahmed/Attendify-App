import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/attendify_teacher.dart';
import 'package:flutter/material.dart';

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
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Card(
            color: Colors.blue[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ListTile(
              enabled: userType == "student" ? modules[index].isActive : true,
              leading: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Icon(
                  Icons.circle_rounded,
                  color: modules[index].isActive ? Colors.green : Colors.red,
                ),
              ),
              trailing: IconButton(
                onPressed: userType == "student"
                    ? !modules[index].isActive
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              '/moduleViewFromStudent',
                              arguments: {
                                'module': modules[index],
                                'student': student,
                              },
                            );
                          }
                    : () {
                        Navigator.pushNamed(
                          context,
                          '/moduleViewFromTeacher',
                          arguments: {
                            'module': modules[index],
                          },
                        );
                      },
                icon: const Icon(Icons.arrow_forward_ios_rounded),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              splashColor: Colors.blue[300],
              contentPadding: const EdgeInsets.all(5.0),
              title: Text(modules[index].name),
              onTap: () {},
            ),
          ),
        );
      },
    );
  }
}
