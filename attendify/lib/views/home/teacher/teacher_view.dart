import 'package:attendify/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/custom_dropdown_btn.dart';
import '../../../models/attendify_teacher.dart';
import '../../../models/module_model.dart';
import '../../../shared/constants.dart';
import '../../../shared/error_pages.dart';
import '../../../shared/loading.dart';
import '../../../shared/module_list_view.dart';
import '../drawer.dart';

class TeacherView extends ConsumerStatefulWidget {
  final Teacher teacher;
  const TeacherView({
    super.key,
    required this.teacher,
  });

  @override
  ConsumerState<TeacherView> createState() => _TeacherViewState();
}

class _TeacherViewState extends ConsumerState<TeacherView> {
  String? gradeVal, specialityVal;
  bool isDisabled = true, showAll = false;

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
    final authService = ref.watch(authServiceProvider);
    final databaseService = ref.watch(databaseServiceProvider);
    final teacherAsyncValue = ref.watch(teacherProvider(authService.currentUsr!.uid));

    return teacherAsyncValue.when(
      data: (teacher) {
        final modulesAsyncValue = ref.watch(teacherModulesProvider(teacher.modules!));
        return modulesAsyncValue.when(
          data: (modulesData) {
            List<Module> filteredModules =
                filterModulesByGradeAndSpeciality(
              modulesData,
              gradeVal ?? "5th",
              specialityVal ?? "",
            );
            if (showAll) {
              filteredModules = modulesData;
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text("Attendify"),
                backgroundColor: Colors.blue[200],
                actions: [
                  IconButton(
                    onPressed: () => authService.logout(),
                    icon: const Icon(Icons.logout_rounded),
                  )
                ],
              ),
              drawer: BuildDrawer(
                authService: authService,
                databaseService: databaseService,
                userType: "teacher",
                teacher: teacher,
                modules: modulesData,
              ),
              body: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
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
                                specialityVal = null;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
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
                                    setState(
                                      () => specialityVal = newValue,
                                    );
                                  },
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (modulesData.isEmpty)
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectModule(
                                      teacher: teacher,
                                      modules: modulesData,
                                    ),
                                  ),
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
                        databaseService: databaseService,
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
          },
          loading: () => const Loading(),
          error: (error, stack) => ErrorPages(
            title: "Server Error",
            message: error.toString(),
          ),
        );
      },
      loading: () => const Loading(),
      error: (error, stack) => ErrorPages(
        title: "Server Error",
        message: error.toString(),
      ),
    );
  }
}
