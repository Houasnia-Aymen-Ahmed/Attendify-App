import 'package:attendify/models/attendify_teacher.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/constants.dart';
import 'package:attendify/views/home/drawer.dart';
import 'package:flutter/material.dart';

import '../../../shared/loading.dart';
import '../../../shared/module_list_view.dart';

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
  //List<String> gradeKeys = modulesMap.keys.toList();
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
          return Text(
            'An error occurred while loading teacher data: ${snapshot.error}',
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
                return Text(snapshot.error.toString());
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
                  /* Drawer(
              child: ListView(
                children: [
                  userAccountDrawerHeader(
                    username: widget.teacher.userName,
                    email: widget.authService.currentUsr?.email ??
                        "user@hns-re2sd.dz",
                  ),
                  ListTile(
                    title: const Text("Add a module"),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectModule(
                            teacher: widget.teacher,
                            modules: modulesData,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ), */
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
                          /* Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              padding: const EdgeInsets.all(8.0),
                              elevation: 16,
                              dropdownColor: Colors.blue[100],
                              borderRadius: BorderRadius.circular(20),
                              value: gradeVal,
                              hint: Text(
                                "Choose your grade",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.blue[900],
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                backgroundColor: Colors.transparent,
                              ),
                              underline: Container(
                                height: 2,
                                color: Colors.blue[900],
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  isDisabled = false;
                                  showAll = false;
                                  gradeVal = newValue;
                                });
                              },
                              items: gradeKeys.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    capitalizeFirst(value),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              padding: const EdgeInsets.all(8.0),
                              elevation: 16,
                              dropdownColor: Colors.blue[100],
                              borderRadius: BorderRadius.circular(20),
                              value: specialityVal,
                              hint: Text(
                                "Choose your speciality",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: isDisabled
                                      ? Colors.blueGrey
                                      : Colors.blue[900],
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                backgroundColor: Colors.transparent,
                              ),
                              underline: Container(
                                height: 2,
                                color: isDisabled
                                    ? Colors.blueGrey
                                    : Colors.blue[900],
                              ),
                              onChanged: isDisabled
                                  ? null
                                  : (String? newValue) {
                                      setState(() {
                                        specialityVal = newValue;
                                      });
                                    },
                              items: modulesMap[gradeVal]
                                  ?.keys
                                  .toList()
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    capitalizeFirst(value),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ), */
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
                          ), /* ListView.builder(
                            itemCount: filteredModules.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Card(
                                  color: Colors.blue[100],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: ListTile(
                                    leading: Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Icon(
                                        Icons.circle_rounded,
                                        color: filteredModules[index].isActive
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/moduleView',
                                          arguments: {
                                            'module': filteredModules[index],
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                          Icons.arrow_forward_ios_rounded),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    splashColor: Colors.blue[300],
                                    contentPadding: const EdgeInsets.all(5.0),
                                    title: Text(filteredModules[index].name),
                                    onTap: () {
                                      showOverlay(
                                          context, overlayEntry, isRoomActive);
                                    },
                                  ),
                                ),
                              );
                            },
                          ), */
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
