import 'package:attendify/services/providers.dart';
import 'package:attendify/views/home/drawer.dart';
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

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        drawer: BuildDrawer(
          authService: ref.read(authServiceProvider),
          databaseService: ref.read(databaseServiceProvider),
          userType: 'admin',
          admin: admin,
        ),
        body: modulesAsync.when(
          data: (modules) => studentsAsync.when(
            data: (students) => teachersAsync.when(
              data: (teachersAndEmails) {
                final activeModules =
                    modules.where((module) => module.isActive).length;
                final inactiveModules = modules.length - activeModules;
                final totalTeachers =
                    (teachersAndEmails['teachers'] as List<dynamic>).length;

                return AttendifyScreen(
                  scrollable: false,
                  expandChild: true,
                  leading: Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                      child: AttendifyUserAvatar(imageUrl: admin.photoURL),
                    ),
                  ),
                  title: 'Admin dashboard',
                  subtitle: 'Manage modules, teachers, and students.',
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
                      // ── Tab bar ──────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AttendifyPalette.surface,
                          borderRadius: AttendifyRadius.lgAll,
                          border: Border.all(color: AttendifyPalette.outline),
                        ),
                        child: const TabBar(
                          dividerColor: Colors.transparent,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          padding: EdgeInsets.zero,
                          indicator: BoxDecoration(
                            color: AttendifyPalette.primary,
                            borderRadius: AttendifyRadius.smAll,
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor: AttendifyPalette.mutedText,
                          labelPadding: EdgeInsets.symmetric(
                            horizontal: AttendifySpacing.lg,
                            vertical: 2,
                          ),
                          tabs: [
                            Tab(text: 'Overview'),
                            Tab(text: 'Modules'),
                            Tab(text: 'Teachers'),
                            Tab(text: 'Students'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AttendifySpacing.lg),

                      // ── Tab content (fills remaining height) ─────────────
                      Expanded(
                        child: TabBarView(
                          children: [
                            // ── Overview ──────────────────────────────────
                            SingleChildScrollView(
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
                                  const SizedBox(height: AttendifySpacing.xl),
                                  AttendifySurface(
                                    color: AttendifyPalette.surfaceMuted,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Quick actions',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(
                                            height: AttendifySpacing.lg),
                                        AttendifyPrimaryButton(
                                          label: 'Add module',
                                          icon: Icons.add_box_rounded,
                                          onPressed: () => _showAddItemDialog(
                                              context, ref, 'module'),
                                        ),
                                        const SizedBox(
                                            height: AttendifySpacing.sm),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: () => _showAddItemDialog(
                                                context, ref, 'teacher email'),
                                            icon: const Icon(
                                                Icons.alternate_email_rounded),
                                            label: const Text(
                                                'Allow teacher email'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── Modules ───────────────────────────────────
                            AllModulesView(
                              dataModules: List<Module>.from(modules),
                            ),

                            // ── Teachers ──────────────────────────────────
                            AllTeachersView(
                              dataTeachers: teachersAndEmails,
                              databaseService: databaseService,
                            ),

                            // ── Students ──────────────────────────────────
                            AllStudentsView(dataStudents: students),
                          ],
                        ),
                      ),
                    ],
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
      ),
    );
  }
}
