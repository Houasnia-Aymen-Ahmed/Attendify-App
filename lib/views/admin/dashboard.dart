import 'package:attendify/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:attendify/models/module_model.dart';
import 'package:attendify/models/user_of_attendify.dart';
import 'package:attendify/shared/error_pages.dart';
import 'package:attendify/shared/loading.dart';
import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/theme/attendify_ui.dart';
import 'package:attendify/views/admin/add_item.dart';
import 'package:attendify/views/admin/all_modules_view.dart';
import 'package:attendify/views/admin/all_students_view.dart';
import 'package:attendify/views/admin/all_teachers_view.dart';
import 'package:attendify/views/admin/dashboard_stats_summary_view.dart';

class Dashboard extends ConsumerWidget {
  final AttendifyUser admin;

  const Dashboard({
    super.key,
    required this.admin,
  });

  void _showAddItemDialog(
    BuildContext context,
    WidgetRef ref,
    String itemType,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AddItemDialog(
        databaseService: ref.read(databaseServiceProvider),
        itemType: itemType,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final databaseService = ref.watch(databaseServiceProvider);
    final modulesAsync = ref.watch(allModulesProvider);
    final studentsAsync = ref.watch(allStudentsProvider);
    final teachersAsync = ref.watch(allTeachersAndEmailsProvider);

    return Scaffold(
      body: modulesAsync.when(
        data: (modules) => studentsAsync.when(
          data: (students) => teachersAsync.when(
            data: (teachersAndEmails) {
              final activeModules =
                  modules.where((module) => module.isActive).length;
              final inactiveModules = modules.length - activeModules;
              final totalTeachers =
                  (teachersAndEmails['teachers'] as List<dynamic>).length;

              return DefaultTabController(
                length: 3,
                child: AttendifyScreen(
                  scrollable: false,
                  expandChild: true,
                  leading: AttendifyUserAvatar(imageUrl: admin.photoURL),
                  title: 'Institution overview',
                  subtitle:
                      'Monitor live attendance health and manage modules, teachers, and students from one place.',
                  actions: [
                    IconButton(
                      tooltip: 'Log out',
                      onPressed: () => authService.logout(context),
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminDashboardStatsSummaryView(
                        totalModules: modules.length,
                        activeModules: activeModules,
                        inactiveModules: inactiveModules,
                        totalTeachers: totalTeachers,
                        totalStudents: students.length,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _showAddItemDialog(context, ref, 'module'),
                              icon: const Icon(Icons.add_box_rounded),
                              label: const Text('Add module'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showAddItemDialog(
                                context,
                                ref,
                                'teacher email',
                              ),
                              icon: const Icon(Icons.alternate_email_rounded),
                              label: const Text('Allow teacher email'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AttendifyPalette.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AttendifyPalette.outline),
                        ),
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: AttendifyPalette.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: AttendifyPalette.mutedText,
                          tabs: const [
                            Tab(text: 'Modules'),
                            Tab(text: 'Teachers'),
                            Tab(text: 'Students'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          children: [
                            AllModulesView(dataModules: List<Module>.from(modules)),
                            AllTeachersView(
                              dataTeachers: teachersAndEmails,
                              databaseService: databaseService,
                            ),
                            AllStudentsView(dataStudents: students),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Loading(),
            error: (error, stackTrace) => ErrorPages(
              title: 'Server Error',
              message: error.toString(),
            ),
          ),
          loading: () => const Loading(),
          error: (error, stackTrace) => ErrorPages(
            title: 'Server Error',
            message: error.toString(),
          ),
        ),
        loading: () => const Loading(),
        error: (error, stackTrace) => ErrorPages(
          title: 'Server Error',
          message: error.toString(),
        ),
      ),
    );
  }
}
