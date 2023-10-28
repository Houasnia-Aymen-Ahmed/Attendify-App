import 'package:attendify/models/attendify_teacher.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/constants.dart';
import 'package:attendify/shared/loading.dart';
import 'package:attendify/views/home/module_select.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherView extends StatefulWidget {
  final Teacher teacher;
  const TeacherView({super.key, required this.teacher});

  @override
  State<TeacherView> createState() => _TeacherViewState();
}

class _TeacherViewState extends State<TeacherView> {
  final DatabaseService _dataService = DatabaseService();
  final AuthService _auth = AuthService();
  String userUid = "";
  List<String> gradeKeys = modulesMap.keys.toList();
  List<Module>? tempList = [];
  String? gradeVal, specialityVal;
  bool isDisabled = true, showAll = false;
  ValueNotifier<bool> isRoomActive = ValueNotifier<bool>(false);
  OverlayEntry? overlayEntry;
  List<Stream<List<Module>>> moduleStreams = [];

  @override
  void initState() {
    super.initState();
    userUid = _auth.currentUsr!.uid;
  }

  List<Module> filterModulesByGradeAndSpeciality(
      List<Module> modules, String grade, String speciality) {
    return modules
        .where((module) =>
            module.grade == grade && module.speciality == speciality)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Teacher>(
      stream: _dataService.getTeacherDataStream(userUid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Loading();
        } else if (snapshot.hasError) {
          return Text(
              'An error occurred while loading data: ${snapshot.error}');
        } else {
          final Teacher teacher = snapshot.data!;
          List<String> moduleUIDs = teacher.modules!;
          return StreamBuilder<List<Module>>(
              stream: _dataService.getModulesOfTeacher(moduleUIDs),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else if (!snapshot.hasData) {
                  return const Loading();
                } else {
                  List<Module> modulesData = snapshot.data!;
                  modulesData[0].uid == "" ? modulesData = [] : modulesData;
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
                              email: _auth.currentUsr?.email),
                          ListTile(
                            title: Text(widget.teacher.userName),
                          ),
                          ListTile(
                            title: const Text("Add a module"),
                            trailing:
                                const Icon(Icons.arrow_forward_ios_rounded),
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
                    ),
                    body: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
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
                            ),
                          ],
                        ),
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
                        if (filteredModules.isNotEmpty)
                          const SizedBox(width: 10),
                        if (filteredModules.isNotEmpty)
                          Expanded(
                            child: ListView.builder(
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
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Icon(Icons.circle_rounded,
                                            color:
                                                filteredModules[index].isActive
                                                    ? Colors.green
                                                    : Colors.red),
                                      ),
                                      trailing: IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/moduleView',
                                            arguments: {
                                              'module': filteredModules[index],
                                              'userType': "teacher"
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                            Icons.arrow_forward_ios_rounded),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      splashColor: Colors.blue[300],
                                      contentPadding: const EdgeInsets.all(5.0),
                                      title: Text(filteredModules[index].name),
                                      onTap: () {
                                        showOverlay(context, overlayEntry,
                                            isRoomActive);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showAll = true;
                                gradeVal = null;
                                specialityVal = null;
                              });
                            },
                            child: const Text("Show all modules"),
                          ),
                        )
                      ],
                    ),
                  );
                }
              });
        }
      },
    );
  }
}
