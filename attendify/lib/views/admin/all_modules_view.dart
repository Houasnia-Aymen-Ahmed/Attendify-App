import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/custom_dropdown_btn.dart';
import '../../models/module_model.dart';
import '../statistics/all/all_stats.dart';
import '../statistics/module_stats.dart';

class AllModulesView extends ConsumerStatefulWidget {
  const AllModulesView({super.key});

  @override
  ConsumerState<AllModulesView> createState() => _AllModulesViewState();
}

class _AllModulesViewState extends ConsumerState<AllModulesView> {
  List<Module> allModules = [], modules = [];
  String? gradeVal, specialityVal;
  bool isDisabled = true;

  List<Module> filterModulesByGradeAndSpeciality(
    List<Module> modules,
    String grade,
    String speciality,
  ) {
    return modules.where((module) {
      return module.grade == grade && module.speciality == speciality;
    }).toList();
  }

  List<Module> filterModulesByGrade(
    List<Module> modules,
    String grade,
  ) {
    return modules.where((module) {
      return module.grade == grade;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final modulesAsyncValue = ref.watch(allModulesProvider);
    return modulesAsyncValue.when(
      data: (allModules) {
        this.allModules = allModules;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: dropDownBtn(
                      hint: "Choose a grade",
                      type: "grade",
                      gradeVal: gradeVal,
                      onChanged: (String? newValue) {
                        setState(() {
                          isDisabled = false;
                          gradeVal = newValue;
                          specialityVal = null;
                          modules = filterModulesByGrade(
                            allModules,
                            gradeVal!,
                          );
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: dropDownBtn(
                      hint: "Choose a speciality",
                      type: "speciality",
                      isDisabled: isDisabled,
                      gradeVal: gradeVal,
                      specialityVal: specialityVal,
                      onChanged: isDisabled
                          ? null
                          : (String? newValue) {
                              setState(() {
                                specialityVal = newValue;
                                modules = filterModulesByGradeAndSpeciality(
                                  allModules,
                                  gradeVal!,
                                  specialityVal!,
                                );
                              });
                            },
                    ),
                  ),
                ),
              ],
            ),
            const AllStats(statType: "modules"),
            Expanded(
              child: ListView.builder(
                itemCount: modules.isEmpty ? allModules.length : modules.length,
                itemBuilder: (context, index) {
                  final module =
                      modules.isEmpty ? allModules[index] : modules[index];
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      color: Colors.blue[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 25.0,
                          vertical: 5.0,
                        ),
                        title: Text(
                          module.name,
                          style: const TextStyle(fontSize: 18),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ModuleStats(
                                moduleId: module.uid,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(error.toString())),
    );
  }
}
