import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/shared/module_list_view.dart';
import 'package:flutter/material.dart';

import '../../models/module_model.dart';
import '../../services/auth.dart';
import '../../services/databases.dart';
import '../../shared/loading.dart';

class BuildBody extends StatefulWidget {
  final Student student;
  final DatabaseService databaseService;
  final AuthService authService;
  const BuildBody({
    super.key,
    required this.student,
    required this.databaseService,
    required this.authService,
  });

  @override
  State<BuildBody> createState() => _BuildBodyState();
}

class _BuildBodyState extends State<BuildBody> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Module>>(
      stream: widget.databaseService.getModuleByGradeSpeciality(
        widget.student.grade!,
        widget.student.speciality!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (snapshot.hasError) {
          return Text(
            'An error accured when loading data ${snapshot.error}',
          );
        } else if (!snapshot.hasData) {
          return const Text('No module data available for student');
        } else {
          List<Module> modules = snapshot.data!;
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(25.0),
                child: Text(
                  'Modules',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ModuleListView(
                  modules: modules,
                  userType: "student",
                  student: widget.student,
                ), /* ListView.builder(
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
                          enabled: modules[index].isActive,
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Icon(Icons.circle_rounded,
                                color: modules[index].isActive
                                    ? Colors.green
                                    : Colors.red),
                          ),
                          trailing: IconButton(
                            onPressed: !modules[index].isActive
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ModuleViewFromStudent(
                                            module: modules[index],
                                            student: widget.student,
                                          );
                                        },
                                      ),
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
                ), */
              ),
            ],
          );
        }
      },
    );
  }
}
