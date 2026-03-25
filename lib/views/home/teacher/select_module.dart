import 'package:attendify/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/custom_dropdown_btn.dart';
import '../../../components/popups.dart';
import '../../../models/attendify_teacher.dart';
import '../../../models/module_model.dart';
import '../../../shared/constants.dart';
import '../../../shared/school_data.dart';

class SelectModule extends ConsumerStatefulWidget {
  final Teacher teacher;
  final List<Module>? modules;
  const SelectModule({
    super.key,
    required this.teacher,
    required this.modules,
  });

  @override
  ConsumerState<SelectModule> createState() => _SelectModuleState();
}

class _SelectModuleState extends ConsumerState<SelectModule> {
  final List<String> _addedModules = [], _selectedModules = [];
  late List<Module> _selectedModulesModel;
  String? _gradeVal, _specialityVal;
  bool _hasSelected = false,
      _isSaved = false,
      _isDisabled = true,
      isSaving = false;

  void addModule(
    String uid,
    String name,
    String grade,
    String speciality,
    bool isActive,
  ) {
    setState(() {
      _selectedModulesModel.add(
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
    _isSaved = false;
    _selectedModulesModel = widget.modules ?? [];
    _selectedModules.clear();
    _selectedModules.addAll(_selectedModulesModel.map((module) => module.uid));
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final databaseService = ref.watch(databaseServiceProvider);
    List<String>? modules = [];
    if (modulesMap.containsKey(_gradeVal) &&
        modulesMap[_gradeVal]?.containsKey(_specialityVal) == true) {
      modules = modulesMap[_gradeVal]![_specialityVal];
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
              authService.logout();
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
              email:
                  authService.currentUsr?.email ?? "user@hns-re2sd.dz",
              profileURL: authService.currentUsr?.photoURL ?? "url",
            ),
            ListTile(
              title: Text(widget.teacher.userName),
            ),
            drawerFooter(),
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomDrowdownBtn(
                    hint: "Choose grade",
                    type: "grade",
                    gradeVal: _gradeVal,
                    onChanged: (String? newValue) {
                      setState(() {
                        _isDisabled = false;
                        _gradeVal = newValue!;
                        _specialityVal = null;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomDrowdownBtn(
                    hint: "Choose speciality",
                    type: "speciality",
                    isDisabled: _isDisabled,
                    gradeVal: _gradeVal,
                    specialityVal: _specialityVal,
                    onChanged: _isDisabled
                        ? null
                        : (String? newValue) =>
                            setState(() => _specialityVal = newValue),
                  ),
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
                        color: _hasSelected ? Colors.black : Colors.blueGrey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: IconButton(
                      onPressed: _hasSelected
                          ? () => setState(
                                () {
                                  _addedModules.clear();
                                  _selectedModules.addAll(
                                    _selectedModulesModel
                                        .map((module) => module.uid),
                                  );
                                  _hasSelected = false;
                                },
                              )
                          : null,
                      icon: const Icon(
                        Icons.unpublished_rounded,
                        color: Colors.blueGrey,
                      ),
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
                            value: _selectedModules.contains(
                                "${_gradeVal}_${_specialityVal}_module_${modules?.indexOf(module)}"),
                            onChanged: (newValue) => setState(() {
                              String moduleName =
                                  "${_gradeVal}_${_specialityVal}_module_${modules?.indexOf(module)}";
                              if (newValue!) {
                                _addedModules.add(moduleName);
                                _selectedModules.add(moduleName);
                              } else {
                                _addedModules.remove(moduleName);
                                _selectedModules.remove(moduleName);
                              }
                              _hasSelected = _addedModules.isNotEmpty;
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
                  onPressed: _addedModules.isEmpty
                      ? null
                      : () async {
                          showLoadingDialog(
                            context,
                            "Saving modules ...",
                          );
                          try {
                            setState(() => isSaving = true);
                            for (String module in _addedModules) {
                              List<String> moduleInfo = module.split('_');
                              String grade = moduleInfo[0];
                              String speciality = moduleInfo[1];
                              int moduleIndex = int.parse(
                                  moduleInfo[3].toString().padLeft(2, '0'));
                              String moduleName =
                                  modulesMap[grade]![speciality]![moduleIndex];
                              await databaseService
                                  .updateModuleSpecificData(
                                uid: module,
                                name: moduleName,
                                isActive: false,
                                speciality: speciality,
                                grade: grade,
                              );
                              addModule(
                                module,
                                moduleName,
                                grade,
                                speciality,
                                false,
                              );
                            }
                            await databaseService
                                .updateTeacherSpecificData(
                              modules: _addedModules,
                            );

                            if (context.mounted) {
                              Navigator.of(context).pop();
                              showDialogBox(
                                context,
                                "Success",
                                "Modules saved successfully",
                                false,
                              );
                            }
                            setState(() => _isSaved = true);
                          } catch (e) {
                            setState(() => isSaving = false);
                            if (context.mounted) {
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
                    if (_addedModules.isNotEmpty && !_isSaved) {
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
