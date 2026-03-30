import 'package:flutter/material.dart';

import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/attendify_teacher.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/theme/attendify_ui.dart';
import 'package:attendify/utils/module_metrics.dart';

class ModuleListView extends StatelessWidget {
  final List<Module> modules;
  final DatabaseService databaseService;
  final String userType;
  final Student? student;
  final Teacher? teacher;
  final bool shrinkWrap;

  const ModuleListView({
    super.key,
    required this.modules,
    required this.databaseService,
    required this.userType,
    this.student,
    this.teacher,
    this.shrinkWrap = false,
  });

  VoidCallback? _gotoModule(BuildContext context, Module module) {
    if (userType == 'student') {
      if (!module.isActive) {
        return null;
      }
      return () => Navigator.pushNamed(
            context,
            '/moduleViewFromStudent',
            arguments: {
              'module': module,
              'student': student,
              'databaseService': databaseService,
            },
          );
    }

    return () => Navigator.pushNamed(
          context,
          '/moduleViewFromTeacher',
          arguments: {
            'module': module,
            'databaseService': databaseService,
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return const SizedBox.shrink();
    }

    final orderedModules = [...modules]
      ..sort((left, right) => left.name.toLowerCase().compareTo(right.name.toLowerCase()));

    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: orderedModules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final module = orderedModules[index];
        final onTap = _gotoModule(context, module);
        final attendanceRate = moduleAttendancePercentage(module);
        final studentCount = moduleStudentCount(module);

        return Opacity(
          opacity: userType == 'student' && !module.isActive ? 0.62 : 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: AttendifySurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                module.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${module.grade} year • ${module.speciality}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AttendifyPalette.mutedText,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        AttendifyStatusChip(
                          label: module.isActive ? 'Session active' : 'Inactive',
                          color: module.isActive
                              ? AttendifyPalette.secondary
                              : AttendifyPalette.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _ModuleMetric(
                            label: 'Students',
                            value: '$studentCount',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModuleMetric(
                            label: 'Attendance',
                            value: '${attendanceRate.toStringAsFixed(0)}%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            userType == 'student'
                                ? module.isActive
                                    ? 'Open the module to confirm your check-in and review history.'
                                    : 'This module becomes interactive only while the teacher session is open.'
                                : 'Open the module to manage today’s session, attendance, and exports.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AttendifyPalette.mutedText,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AttendifyPalette.surfaceMuted,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AttendifyPalette.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ModuleMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ModuleMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AttendifyPalette.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
