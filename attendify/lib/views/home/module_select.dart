import 'package:attendify/models/attendify_teacher.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectModule extends StatefulWidget {
  final Teacher teacher;
  final List<Module> modules;
  const SelectModule({super.key, required this.teacher, required this.modules});

  @override
  State<SelectModule> createState() => _SelectModuleState();
}

class _SelectModuleState extends State<SelectModule> {
  List<String> addedModules = [];
  List<String> selectedModules = [];
  late List<Module> selectedModulesModel;
  String? selectedGrade, selectedSpeciality;
  bool hasSelected = false, isSaved = false, isDisabled = true;
  final DatabaseService _databaseService = DatabaseService();

  void addModule(
      String uid, String name, String grade, String speciality, bool isActive) {
    setState(() {
      selectedModulesModel.add(
        Module(
          uid: uid,
          grade: grade,
          isActive: isActive,
          name: name,
          speciality: speciality,
        ),
      );
    });
  }

  Future<void> showCloseConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Exit'),
          content: const Text(
              'You have unsaved changes. Do you want to exit without saving?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Back'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Exit Anyway'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    isSaved = false;
    selectedModulesModel = widget.modules;
    selectedModules.clear();
    selectedModules.addAll(selectedModulesModel.map((module) => module.uid));
    /* selectedModules =
        widget.teacher.modules?.map((module) => /* get data from moduleColl */  ).toList() ??
            <String>[]; */
  }

  @override
  Widget build(BuildContext context) {
    List<String>? modules = [];
    if (modulesMap.containsKey(selectedGrade) &&
        modulesMap[selectedGrade]?.containsKey(selectedSpeciality) == true) {
      modules = modulesMap[selectedGrade]![selectedSpeciality];
      if (modules?[0] == "") {
        modules = null;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendify"),
        backgroundColor: Colors.blue[200],
        actions: [
          IconButton(
            onPressed: () {
              AuthService().logout(context);
            },
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            userAccountDrawerHeader(
                username: widget.teacher.userName,
                email: AuthService().currentUsr?.email),
            ListTile(
              title: Text(widget.teacher.userName),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  padding: const EdgeInsets.all(8.0),
                  elevation: 16,
                  dropdownColor: Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                  value: selectedGrade,
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
                      selectedGrade = newValue!;
                    });
                  },
                  items: modulesMap.keys.map((String value) {
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
                  value: selectedSpeciality,
                  hint: Text(
                    "Choose your speciality",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: isDisabled ? Colors.blueGrey : Colors.blue[900],
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    backgroundColor: Colors.transparent,
                  ),
                  underline: Container(
                    height: 2,
                    color: isDisabled ? Colors.blueGrey : Colors.blue[900],
                  ),
                  onChanged: isDisabled
                      ? null
                      : (String? newValue) {
                          setState(() {
                            selectedSpeciality = newValue!;
                          });
                        },
                  items: modulesMap[selectedGrade ?? "5th"]!
                      .keys
                      .map((String value) {
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
            ],
          ),
          if (hasSelected)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Unselect all",
                        style: TextStyle(fontSize: 17.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: IconButton(
                        onPressed: () => setState(
                          () {
                            addedModules.clear();
                            selectedModules.addAll(selectedModulesModel
                                .map((module) => module.uid));
                            hasSelected = false;
                          },
                        ),
                        icon: const Icon(Icons.unpublished_rounded),
                      ),
                    )
                    /**/
                  ],
                ),
                const Divider(
                  height: 20,
                  color: Colors.blueGrey,
                )
              ],
            ),
          Expanded(
            child: modules == null
                ? const Center(child: Text("No module availabe"))
                : ListView(
                    children: modules
                        .map(
                          (module) => CheckboxListTile(
                            title: Text(module),
                            value: selectedModules.contains(
                                "${selectedGrade}_${selectedSpeciality}_module_${modules?.indexOf(module)}"),
                            onChanged: (newValue) {
                              setState(() {
                                String moduleName =
                                    "${selectedGrade}_${selectedSpeciality}_module_${modules?.indexOf(module)}";
                                if (newValue!) {
                                  addedModules.add(moduleName);
                                  selectedModules.add(moduleName);
                                } else {
                                  addedModules.remove(moduleName);
                                  selectedModules.remove(moduleName);
                                }
                                hasSelected = addedModules.isNotEmpty;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              textDirection: TextDirection.rtl,
              children: [
                ElevatedButton(
                  onPressed: addedModules.isEmpty
                      ? null
                      : () async {
                          try {
                            for (String module in addedModules) {
                              List<String> moduleInfo = module.split('_');
                              String grade = moduleInfo[0];
                              String speciality = moduleInfo[1];
                              int moduleIndex = int.parse(moduleInfo[3]);
                              String moduleName =
                                  modulesMap[grade]![speciality]![moduleIndex];
                              //print(addedModules.toString());
                              await _databaseService.updateModuleData(
                                uid: module,
                                name: moduleName,
                                isActive: false,
                                speciality: speciality,
                                grade: grade,
                                students: {},
                                attendanceTable: {},
                                checkExists: true,
                              );
                              addModule(
                                module,
                                moduleName,
                                grade,
                                speciality,
                                false,
                              );
                            }
                            await _databaseService.updateTeacherSpecificData(
                              modules: addedModules,
                            );

                            if (mounted) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Success',
                                      style: TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                    content: const Text(
                                        "Modules saved successfully"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                            setState(() {
                              isSaved = true;
                            });
                          } catch (e) {
                            if (mounted) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Error',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                    content: Text("Error saving modules: $e"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        },
                  child: const Text("Submit"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (addedModules.isNotEmpty && !isSaved) {
                      await showCloseConfirmationDialog(context);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
