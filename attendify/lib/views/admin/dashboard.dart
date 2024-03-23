import 'package:attendify/services/providers.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/user_of_attendify.dart';
import '../../shared/constants.dart';
import '../../utils/shared_prefs_helper.dart';
import 'add_item.dart';
import 'all_modules_view.dart';
import 'all_teachers_view.dart';
import 'search_page.dart';
import 'dashboard_stats_summary_view.dart';

class Dashboard extends ConsumerStatefulWidget {
  final AttendifyUser admin;
  const Dashboard({
    super.key,
    required this.admin,
  });
  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  int index = 1, _selectedListTileIndex = -1;

  final List<String> itemTypes = ["module", "teacher email"];
  final List<String> itemsTypes = ["teacher", "module", "student"];
  final navigationKey = GlobalKey<CurvedNavigationBarState>();

  final imageItems = <Widget>[
    imageItem(FontAwesomeIcons.personChalkboard),
    imageItem(FontAwesomeIcons.bookOpenReader),
  ];

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

  void _showAddItemDialog(BuildContext context, String itemType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddItemDialog(
          databaseService: ref.read(databaseServiceProvider),
          itemType: itemType,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = ref.watch(databaseServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final modulesAsyncValue = ref.watch(allModulesProvider);
    final studentsAsyncValue = ref.watch(allStudentsProvider);
    final teachersAsyncValue = ref.watch(allTeachersAndEmailsProvider);

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
                dynamic currentAllItems;
                if (index == 0) {
                  currentAllItems = teachersAsyncValue.value?['teachers'] ?? [];
                } else if (index == 1) {
                  currentAllItems = modulesAsyncValue.value ?? [];
                } else {
                  currentAllItems = studentsAsyncValue.value ?? [];
                }

                showSearch(
                  // ignore: use_build_context_synchronously
                  context: context,
                  delegate: SearchPage(
                    itemType: itemsTypes[index],
                    lastAccessedItems:
                        await SharedPrefsHelper.getLastAccessedItems(
                      itemsTypes[index],
                    ),
                    allItems: currentAllItems,
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
        body: modulesAsyncValue.when(
          data: (modules) => studentsAsyncValue.when(
            data: (students) => teachersAsyncValue.when(
              data: (teachersAndEmails) {
                int totalModules = modules.length;
                int activeModules = modules.where((m) => m.isActive).length;
                int inactiveModules = totalModules - activeModules;
                int totalTeachers = (teachersAndEmails['teachers'] as List).length;
                int totalStudents = students.length;

                Widget screen;
                switch (index) {
                  case 0:
                    screen = AllTeachersView(
                      dataTeachers: teachersAndEmails,
                    );
                    break;
                  case 1:
                    screen = AllModulesView(dataModules: modules);
                    break;
                  case 2:
                    screen = AllStudentsView(dataStudents: students);
                    break;
                  default:
                    screen = Container();
                }

                return Column(
                  children: [
                    AdminDashboardStatsSummaryView(
                      totalModules: totalModules,
                      activeModules: activeModules,
                      inactiveModules: inactiveModules,
                      totalTeachers: totalTeachers,
                      totalStudents: totalStudents,
                    ),
                    Expanded(
                      child: screen,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text(error.toString())),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text(error.toString())),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text(error.toString())),
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
                      email: authService.currentUsr?.email ?? "email",
                      profileURL: widget.admin.photoURL,
                      hasLogout: true,
                      onLogout: () async {
                        final bool success = await authService.logout();
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
                      onTap: (idx) => _onItemTapped(
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
