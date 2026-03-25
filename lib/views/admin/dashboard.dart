import 'package:attendify/services/providers.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../components/drawer_footer.dart';
import '../../components/image_item.dart';
import '../../components/user_account_drawer_header.dart';
import '../../models/module_model.dart';
import '../../models/user_of_attendify.dart';
import '../../shared/constants.dart';
import '../../utils/shared_prefs_helper.dart';
import 'add_item.dart';
import 'all_modules_view.dart';
import 'all_teachers_view.dart';
import 'dashboard_stats_summary_view.dart';
import 'search_page.dart';

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
  final List<String> itemsTypes = ["teacher", "module"];
  final navigationKey = GlobalKey<CurvedNavigationBarState>();

  final imageItems = <Widget>[
    const ImageItem(icon: FontAwesomeIcons.personChalkboard),
    const ImageItem(icon: FontAwesomeIcons.bookOpenReader)
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
    final authService = ref.watch(authServiceProvider);
    final databaseService = ref.watch(databaseServiceProvider);
    final modulesAsync = ref.watch(allModulesProvider);
    final studentsAsync = ref.watch(allStudentsProvider);
    final teachersAsync = ref.watch(allTeachersAndEmailsProvider);
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
                final loadedModules = modulesAsync.value ?? <Module>[];
                final loadedTeachers = teachersAsync.value?['teachers'] ?? <dynamic>[];
                showSearch(
                  // ignore: use_build_context_synchronously
                  context: context,
                  delegate: SearchPage(
                    itemType: itemsTypes[index],
                    lastAccessedItems:
                        await SharedPrefsHelper.getLastAccessedItems(
                      itemsTypes[index],
                    ),
                    allItems: index == 0
                        ? loadedTeachers
                        : loadedModules,
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
        body: modulesAsync.when(
          data: (modules) => studentsAsync.when(
            data: (students) => teachersAsync.when(
              data: (teachersAndEmails) {
                final activeModules = modules.where((module) => module.isActive).length;
                final inactiveModules = modules.length - activeModules;
                final totalTeachers =
                    (teachersAndEmails['teachers'] as List<dynamic>).length;

                Widget screen;
                switch (index) {
                  case 0:
                    screen = AllTeachersView(
                      dataTeachers: teachersAndEmails,
                      databaseService: databaseService,
                    );
                    break;
                  case 1:
                    screen = AllModulesView(dataModules: modules);
                    break;
                  default:
                    screen = const SizedBox.shrink();
                }

                return Column(
                  children: [
                    AdminDashboardStatsSummaryView(
                      totalModules: modules.length,
                      activeModules: activeModules,
                      inactiveModules: inactiveModules,
                      totalTeachers: totalTeachers,
                      totalStudents: students.length,
                    ),
                    Expanded(child: screen),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text(error.toString())),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
        ),
        drawer: Drawer(
          backgroundColor: Colors.blue[100],
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    UserAccountDrawerHeader(
                      username: widget.admin.userName,
                      email: authService.currentUsr?.email ?? "email",
                      profileURL: widget.admin.photoURL,
                      hasLogout: true,
                      onLogout: () => authService.logout(context),
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
              const DrawerFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
