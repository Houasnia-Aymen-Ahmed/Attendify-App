import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/attendify_student.dart';
import '../../models/module_model.dart';
import '../../models/user_of_attendify.dart';
import '../../services/auth.dart';
import '../../services/databases.dart';
import '../../shared/constants.dart';
import '../../utils/shared_prefs_helper.dart';
import 'add_item.dart';
import 'all_modules_view.dart';
import 'all_students_view.dart';
import 'all_teachers_view.dart';
import 'search_page.dart';

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

  late List<Module>? modules;
  late List<Student>? students;
  late Map<String, dynamic>? teachersAndEmails;
  final List<String> itemTypes = ["module", "teacher email"];
  final List<String> itemsTypes = ["teacher", "module", "student"];
  final navigationKey = GlobalKey<CurvedNavigationBarState>();

  Widget screens(int index, dynamic data) {
    switch (index) {
      case 0:
        return AllTeachersView(
          dataTeachers: data as Map<String, dynamic>,
          databaseService: widget.databaseService,
        );
      case 1:
        return AllModulesView(dataModules: data as List<Module>);
      case 2:
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

  Future<dynamic> getData(index) {
    switch (index) {
      case 0:
        return widget.databaseService.getAllTeachers();
      case 1:
        return widget.databaseService.getAllModules();
      case 2:
        return widget.databaseService.getAllStudents();
      default:
        return [] as Future<dynamic>;
    }
  }

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
    teachersAndEmails = widget.data["teachersAndEmails"];
    modules = widget.data["modules"];
    students = widget.data["students"];
    args = [teachersAndEmails, modules, students];
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

  Future<List<String>> getLastAccessedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? accessedItems = prefs.getStringList('lastAccessedItems');
    return accessedItems ?? [];
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenSizeWidth = screenSize.width,
        screenSizeHeight = screenSize.height;
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
                showSearch(
                  context: context,
                  delegate: SearchPage(
                    itemType: itemsTypes[index],
                    lastAccessedItems:
                        await SharedPrefsHelper.getLastAccessedItems(
                      itemsTypes[index],
                    ),
                    allItems: index == 0
                        ? await (args[index]
                            as Map<String, dynamic>)['teachers']
                        : await args[index],
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
            onTap: (index) => setState(() => this.index = index),
          ),
        ),
        body: screens(index, args[index]),
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
                      onLogout: () => widget.authService.logout(context),
                    ),
                    const SizedBox(height: 10),
                    ...dashboardDrawerList(
                      context: context,
                      selectedIndex: _selectedListTileIndex,
                      onTap: (index) => _onItemTapped(
                        index,
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
