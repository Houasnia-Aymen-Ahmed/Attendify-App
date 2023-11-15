import 'package:flutter/material.dart';

import '../../../models/attendify_teacher.dart';
import '../../../models/module_model.dart';
import '../../../services/auth.dart';
import '../../../services/databases.dart';
import '../../../shared/constants.dart';
import '../../../shared/error_pages.dart';
import '../../../shared/loading.dart';
import '../../../shared/module_list_view.dart';
import '../drawer.dart';

class TeacherView extends StatefulWidget {
  final Teacher teacher;
  final DatabaseService databaseService;
  final AuthService authService;
  const TeacherView({
    super.key,
    required this.teacher,
    required this.databaseService,
    required this.authService,
  });

  @override
  State<TeacherView> createState() => _TeacherViewState();
}

class _TeacherViewState extends State<TeacherView> {
  String? gradeVal, specialityVal;
  bool isDisabled = true, showAll = false;
  List<Module>? modulesData;

  List<Module> filterModulesByGradeAndSpeciality(
    List<Module> modules,
    String grade,
    String speciality,
  ) {
    return modules
        .where((module) =>
            module.grade == grade && module.speciality == speciality)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Teacher>(
      stream: widget.databaseService
          .getTeacherDataStream(widget.authService.currentUsr!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorPages(
            title: "Server Error",
            message: snapshot.error.toString(),
          );
        } else if (!snapshot.hasData) {
          return const Loading();
        } else {
          final Teacher teacher = snapshot.data!;
          List<String> moduleUIDs = teacher.modules!;
          return StreamBuilder<List<Module>>(
            stream: widget.databaseService.getModulesOfTeacher(moduleUIDs),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorPages(
                  title: "Server Error",
                  message: snapshot.error.toString(),
                );
              } else if (!snapshot.hasData) {
                return const Loading();
              } else {
                modulesData = snapshot.data!;
                List<Module> filteredModules =
                    filterModulesByGradeAndSpeciality(
                  modulesData!,
                  gradeVal ?? "5th",
                  specialityVal ?? "",
                );
                if (showAll) {
                  filteredModules = modulesData!;
                }
                return Scaffold(
                  appBar: AppBar(
                    title: const Text("Attendify"),
                    backgroundColor: Colors.blue[200],
                    actions: [
                      IconButton(
                        onPressed: () => widget.authService.logout(context),
                        icon: const Icon(Icons.logout_rounded),
                      )
                    ],
                  ),
                  drawer: BuildDrawer(
                    authService: widget.authService,
                    databaseService: widget.databaseService,
                    userType: "teacher",
                    teacher: teacher,
                    modules: modulesData ?? [],
                  ),
                  body: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: dropDownBtn(
                              hint: "Choose your grade",
                              type: "grade",
                              gradeVal: gradeVal,
                              onChanged: (String? newValue) {
                                setState(() {
                                  isDisabled = false;
                                  showAll = false;
                                  gradeVal = newValue;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: dropDownBtn(
                              hint: "Choose your speciality",
                              type: "speciality",
                              isDisabled: isDisabled,
                              gradeVal: gradeVal,
                              specialityVal: specialityVal,
                              onChanged: isDisabled
                                  ? null
                                  : (String? newValue) {
                                      setState(() {
                                        specialityVal = newValue;
                                      });
                                    },
                            ),
                          ),
                        ],
                      ),
                      if (modulesData!.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 250),
                                  child: Text(
                                    "You haven't select any modules",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 25.0,
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/selectModule',
                                      arguments: {
                                        'modules': modulesData,
                                        'teacher': teacher,
                                        'databaseService':
                                            widget.databaseService,
                                        'authService': widget.authService,
                                      },
                                    );
                                  },
                                  child: Text(
                                    "click to add modules",
                                    style: TextStyle(color: Colors.red[900]),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      else
                        filteredModules.isNotEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Modules',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : gradeVal == null
                                ? Expanded(
                                    child: Center(
                                      child: Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 250),
                                        child: const Text(
                                          "Please select a grade and a speciality to show your modules",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 25.0,
                                            color: Colors.blueGrey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    child: Center(
                                      child: Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 250),
                                        child: const Text(
                                          "No modules available for this grade & speciality",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 25.0,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                      if (filteredModules.isNotEmpty) const SizedBox(width: 10),
                      if (filteredModules.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: ModuleListView(
                            modules: filteredModules,
                            userType: "teacher",
                            teacher: widget.teacher,
                          ),
                        ),
                      ],
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showAll = true;
                            gradeVal = null;
                            specialityVal = null;
                          });
                        },
                        child: const Text("Show all modules"),
                      ),
                      const SizedBox(height: 10),
                    ],
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
