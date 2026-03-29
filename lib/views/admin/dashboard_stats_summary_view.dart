import 'package:flutter/material.dart';

import 'package:attendify/theme/attendify_ui.dart';

class AdminDashboardStatsSummaryView extends StatelessWidget {
  final int totalModules;
  final int activeModules;
  final int inactiveModules;
  final int totalTeachers;
  final int totalStudents;

  const AdminDashboardStatsSummaryView({
    super.key,
    required this.totalModules,
    required this.activeModules,
    required this.inactiveModules,
    required this.totalTeachers,
    required this.totalStudents,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 820;
        final medium = constraints.maxWidth > 540;
        final columns = wide
            ? 3
            : medium
                ? 2
                : 1;
        final itemWidth =
            (constraints.maxWidth - (12 * (columns - 1))) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: itemWidth,
              child: AttendifyMetricCard(
                label: 'Total modules',
                value: '$totalModules',
                helper: '$activeModules active • $inactiveModules inactive',
                icon: Icons.menu_book_rounded,
                emphasized: true,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AttendifyMetricCard(
                label: 'Teachers',
                value: '$totalTeachers',
                helper: 'Registered teaching staff',
                icon: Icons.co_present_rounded,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AttendifyMetricCard(
                label: 'Students',
                value: '$totalStudents',
                helper: 'Currently enrolled accounts',
                icon: Icons.school_rounded,
              ),
            ),
          ],
        );
      },
    );
  }
}
