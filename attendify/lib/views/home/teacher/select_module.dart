import 'package:flutter/material.dart';

import '../../../models/attendify_teacher.dart';
import '../../../models/module_model.dart';
import '../../../services/auth.dart';
import '../../../services/databases.dart';
import '../../../shared/constants.dart';

class SelectModule extends StatefulWidget {
  final Teacher teacher;
  final List<Module>? modules;
  final DatabaseService databaseService;
  final AuthService authService;
  const SelectModule({
    super.key,
    required this.teacher,
    required this.modules,
    required this.databaseService,
    required this.authService,
  });

  @override
  State<SelectModule> createState() => _SelectModuleState();
}

class _SelectModuleState extends State<SelectModule> {
  List<String> addedModules = [];
  List<String> selectedModules = [];
  late List<Module> selectedModulesModel;
  String? gradeVal, specialityVal;
  bool hasSelected = false,
      isSaved = false,
      isDisabled = true,
      isSaving = false;

  void addModule(
    String uid,
    String name,
    String grade,
    String speciality,
    bool isActive,
  ) {
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

  @override
  void initState() {
    super.initState();
    isSaved = false;
    selectedModulesModel = widget.modules ?? [];
    selectedModules.clear();
    selectedModules.addAll(selectedModulesModel.map((module) => module.uid));
  }

  @override
  Widget build(BuildContext context) {
    List<String>? modules = [];
    if (modulesMap.containsKey(gradeVal) &&
        modulesMap[gradeVal]?.containsKey(specialityVal) == true) {
      modules = modulesMap[gradeVal]![specialityVal];
      if (modules?[0] == "") {
        modules = null;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select modules"),
        backgroundColor: Colors.blue[200],
        actions: [
          IconButton(
            onPressed: () {
              widget.authService.logout(context);
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
                email: widget.authService.currentUsr?.email ??
                    "user@hns-re2sd.dz"),
            ListTile(
              title: Text(widget.teacher.userName),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: dropDownBtn(
                  hint: "Select a grade",
                  type: "grade",
                  gradeVal: gradeVal,
                  onChanged: (String? newValue) {
                    setState(() {
                      isDisabled = false;
                      gradeVal = newValue!;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: dropDownBtn(
                  hint: "Select a speciality",
                  type: "speciality",
                  gradeVal: gradeVal,
                  specialityVal: specialityVal,
                  onChanged: isDisabled
                      ? null
                      : (String? newValue) =>
                          setState(() => specialityVal = newValue!),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      "Unselect new selected modules",
                      style: TextStyle(
                        fontSize: 17.5,
                        color: hasSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: IconButton(
                      onPressed: hasSelected
                          ? () => setState(
                                () {
                                  addedModules.clear();
                                  selectedModules.addAll(selectedModulesModel
                                      .map((module) => module.uid));
                                  hasSelected = false;
                                },
                              )
                          : null,
                      icon: const Icon(Icons.unpublished_rounded),
                    ),
                  )
                ],
              ),
              const Divider(
                height: 20,
                indent: 16,
                endIndent: 16,
                color: Colors.blueGrey,
              )
            ],
          ),
          Expanded(
            child: modules == null
                ? const Center(
                    child: Text("No module availabe"),
                  )
                : ListView(
                    children: modules
                        .map(
                          (module) => CheckboxListTile(
                            title: Text(module),
                            value: selectedModules.contains(
                                "${gradeVal}_${specialityVal}_module_${modules?.indexOf(module)}"),
                            onChanged: (newValue) => setState(() {
                              String moduleName =
                                  "${gradeVal}_${specialityVal}_module_${modules?.indexOf(module)}";
                              if (newValue!) {
                                addedModules.add(moduleName);
                                selectedModules.add(moduleName);
                              } else {
                                addedModules.remove(moduleName);
                                selectedModules.remove(moduleName);
                              }
                              hasSelected = addedModules.isNotEmpty;
                            }),
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
                          showLoadingDialog(
                            context,
                            "Saving modules ...",
                          );
                          try {
                            setState(() => isSaving = true);
                            for (String module in addedModules) {
                              List<String> moduleInfo = module.split('_');
                              String grade = moduleInfo[0];
                              String speciality = moduleInfo[1];
                              int moduleIndex = int.parse(moduleInfo[3]);
                              String moduleName =
                                  modulesMap[grade]![speciality]![moduleIndex];
                              await widget.databaseService.updateModuleData(
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
                            await widget.databaseService
                                .updateTeacherSpecificData(
                              modules: addedModules,
                            );

                            if (mounted) {
                              Navigator.of(context).pop();
                              showDialogBox(
                                context,
                                "Success",
                                "Modules saved successfully",
                                false,
                              );
                            }
                            setState(() => isSaved = true);
                          } catch (e) {
                            setState(() => isSaving = false);
                            if (mounted) {
                              Navigator.of(context).pop();
                              showDialogBox(
                                context,
                                "Error",
                                "Error saving modules: $e",
                                true,
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
