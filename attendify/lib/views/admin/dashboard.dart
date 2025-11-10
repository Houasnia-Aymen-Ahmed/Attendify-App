import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/attendify_student.dart';
import '../../models/module_model.dart';
import '../../models/user_of_attendify.dart';
import '../../models/attendify_teacher.dart'; // Added for type casting
import '../../services/auth.dart';
import '../../services/databases.dart';
import '../../shared/constants.dart';
import '../../utils/shared_prefs_helper.dart';
import 'add_item.dart';
import 'all_modules_view.dart';
import 'all_students_view.dart';
import 'all_teachers_view.dart';
import 'search_page.dart';
import 'dashboard_stats_summary_view.dart'; // Import the new summary view

class Dashboard extends StatefulWidget {
  final AttendifyUser admin;
  final DatabaseService databaseService;
  final AuthService authService;
  final Map<String, dynamic> data;
  const Dashboard({
    super.key,
    required this.admin,
    required this.databaseService,
    required this.authService,
    required this.data,
  });
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int index = 1, _selectedListTileIndex = -1;
  List<dynamic> args = [];

  // These will be initialized from widget.data in initState
  late List<Module> modulesList;
  late List<Student> studentsList;
  late List<Teacher> teachersList;

  final List<String> itemTypes = ["module", "teacher email"];
  final List<String> itemsTypes = ["teacher", "module", "student"];
  final navigationKey = GlobalKey<CurvedNavigationBarState>();

  Widget screens(int index, dynamic data) {
    switch (index) {
      case 0:
        return AllTeachersView(
          // Assuming data here is the combined map teachersAndEmails
          dataTeachers: data as Map<String, dynamic>,
          databaseService: widget.databaseService,
        );
      case 1:
        // data for modules is List<Module>
        return AllModulesView(dataModules: data as List<Module>);
      case 2:
        // data for students is List<Student>
        return AllStudentsView(dataStudents: data as List<Student>);
      default:
        return Container();
    }
  }

  final imageItems = <Widget>[
    imageItem(FontAwesomeIcons.personChalkboard),
    imageItem(FontAwesomeIcons.bookOpenReader),
    imageItem(FontAwesomeIcons.graduationCap),
  ];

  // This getData method seems unused if data is passed via constructor and args
  // Future<dynamic> getData(index) { ... }

  void _onItemTapped(
    int index,
    double screenSizeWidth,
    double screenSizeHeight,
  ) {
    setState(() {
      _selectedListTileIndex = index;
    });
    _selectedListTileIndex < 2
        ? _showAddItemDialog(context, itemTypes[_selectedListTileIndex])
        : showSettingsPage();
  }

  void showSettingsPage() {
    /**
     * todo add settings page
     */
  }

  @override
  void initState() {
    super.initState();
    // Initialize local lists from widget.data for clarity and type safety
    modulesList = List<Module>.from(widget.data["modules"] ?? []);
    studentsList = List<Student>.from(widget.data["students"] ?? []);
    // teachersAndEmails is a Map<String, dynamic> containing 'teachers' (List<Teacher>) and 'emails' (List<String>)
    Map<String, dynamic> teachersDataMap = widget.data["teachersAndEmails"] as Map<String, dynamic>? ?? {'teachers': [], 'emails': []};
    teachersList = List<Teacher>.from(teachersDataMap['teachers'] ?? []);

    // args is used by screens method, ensure it uses the typed lists or the original map structure
    // For simplicity, ensure args matches what screens() expects
    args = [
      teachersDataMap, // For AllTeachersView
      modulesList,     // For AllModulesView
      studentsList     // For AllStudentsView
    ];
  }

  void _showAddItemDialog(BuildContext context, String itemType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddItemDialog(
          databaseService: widget.databaseService,
          itemType: itemType,
        );
      },
    );
  }

  // This method seems unused in the current context of the build method
  // Future<List<String>> getLastAccessedItems() async { ... }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenSizeWidth = screenSize.width,
        screenSizeHeight = screenSize.height;

    // Calculate statistics
    int totalModules = modulesList.length;
    int activeModules = modulesList.where((m) => m.isActive).length;
    int inactiveModules = totalModules - activeModules;
    int totalTeachers = teachersList.length;
    int totalStudents = studentsList.length;

    return SafeArea(
      top: false,
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.blue[200],
          title: const Text(
            "Admin dashboard",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.search,
              ),
              onPressed: () async {
                // Determine the correct list for 'allItems' based on current tab
                dynamic currentAllItems;
                if (index == 0) { // Teachers
                  currentAllItems = teachersList; // Pass the List<Teacher>
                } else if (index == 1) { // Modules
                  currentAllItems = modulesList;
                } else { // Students
                  currentAllItems = studentsList;
                }

                showSearch(
                  context: context,
                  delegate: SearchPage(
                    itemType: itemsTypes[index],
                    lastAccessedItems:
                        await SharedPrefsHelper.getLastAccessedItems( // This still returns List<dynamic>
                      itemsTypes[index],
                    ),
                    allItems: currentAllItems, // Pass the correctly typed list
                    searchLabel: "Search for a ${itemsTypes[index]}",
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.transparent,
          child: CurvedNavigationBar(
            key: navigationKey,
            index: index,
            items: imageItems,
            height: 50,
            backgroundColor: Colors.transparent.withOpacity(0.0),
            color: const Color(0xFF153C77),
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 250),
            onTap: (newIndex) => setState(() => this.index = newIndex),
          ),
        ),
        body: Column( // Added Column to hold StatsSummary and the screens
          children: [
            AdminDashboardStatsSummaryView(
              totalModules: totalModules,
              activeModules: activeModules,
              inactiveModules: inactiveModules,
              totalTeachers: totalTeachers,
              totalStudents: totalStudents,
            ),
            Expanded( // Ensures the screens() widget takes up remaining space
              child: screens(index, args[index]),
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: Colors.blue[100],
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    userAccountDrawerHeader(
                      username: widget.admin.userName,
                      email: widget.authService.currentUsr?.email ?? "email",
                      profileURL: widget.admin.photoURL,
                      hasLogout: true,
                      onLogout: () async {
                        final bool success = await widget.authService.logout();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? "Logged out successfully"
                                  : "Error logging out. Please try again."),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    ...dashboardDrawerList(
                      context: context,
                      selectedIndex: _selectedListTileIndex,
                      onTap: (idx) => _onItemTapped( // Renamed index to idx to avoid conflict
                        idx,
                        screenSizeWidth,
                        screenSizeHeight,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              drawerFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
