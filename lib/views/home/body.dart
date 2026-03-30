import 'package:flutter/material.dart';

import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/error_pages.dart';
import 'package:attendify/shared/loading.dart';
import 'package:attendify/shared/module_list_view.dart';
import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/theme/attendify_ui.dart';

class BuildBody extends StatelessWidget {
  final Student student;
  final DatabaseService databaseService;
  final AuthService authService;

  const BuildBody({
    super.key,
    required this.student,
    required this.databaseService,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Module>>(
      stream: databaseService.getModuleByGradeSpeciality(
        student.grade!,
        student.speciality!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (snapshot.hasError) {
          return ErrorPages(
            title: 'Server Error',
            message: snapshot.error.toString(),
          );
        } else if (!snapshot.hasData) {
          return const ErrorPages(
            title: 'Error 404: Not Found',
            message: 'No module data available for student',
          );
        }

        final modules = snapshot.data!;
        final activeModules = modules.where((module) => module.isActive).length;

        return Scaffold(
          body: AttendifyScreen(
            leading: AttendifyUserAvatar(imageUrl: student.photoURL),
            title: 'Attendance overview',
            subtitle:
                '${student.grade} year • ${student.speciality} • ${modules.length} modules in your track',
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 560;
                    final itemWidth =
                        wide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
                    return Wrap(
                      spacing: AttendifySpacing.md,
                      runSpacing: AttendifySpacing.md,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: AttendifyMetricCard(
                            label: 'Active modules',
                            value: '$activeModules',
                            helper:
                                '${modules.length - activeModules} waiting for a live session',
                            icon: Icons.bolt_rounded,
                            emphasized: true,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: AttendifyMetricCard(
                            label: 'Academic track',
                            value: student.grade ?? '-',
                            helper: student.speciality ?? 'No speciality assigned',
                            icon: Icons.school_rounded,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AttendifySpacing.xl),
                AttendifySurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your modules',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Open an active module to confirm attendance and review your history.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AttendifyPalette.mutedText,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AttendifySpacing.lg),
                modules.isEmpty
                    ? const AttendifyEmptyState(
                        title: 'No modules available',
                        message:
                            'Your academic track has no published modules yet. Please check again later.',
                      )
                    : ModuleListView(
                        modules: modules,
                        userType: 'student',
                        student: student,
                        databaseService: databaseService,
                        shrinkWrap: true,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
