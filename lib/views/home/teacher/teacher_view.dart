import 'package:flutter/material.dart';

import 'package:attendify/models/attendify_teacher.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/error_pages.dart';
import 'package:attendify/shared/loading.dart';
import 'package:attendify/shared/module_list_view.dart';
import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/theme/attendify_ui.dart';
import 'package:attendify/utils/module_metrics.dart';
import 'package:attendify/views/home/drawer.dart';

class TeacherView extends StatefulWidget {
  final Teacher teacher;
  final DatabaseService databaseService;
  final AuthService authService;

  const TeacherView({
    super.key,
    required this.teacher,
    required this.databaseService,
    required this.authService,
  });

  @override
  State<TeacherView> createState() => _TeacherViewState();
}

class _TeacherViewState extends State<TeacherView> {
  String? gradeVal;
  String? specialityVal;

  List<Module> _filterModules(List<Module> modules) {
    return modules.where((module) {
      final gradeMatches = gradeVal == null || module.grade == gradeVal;
      final specialityMatches =
          specialityVal == null || module.speciality == specialityVal;
      return gradeMatches && specialityMatches;
    }).toList();
  }

  List<String> _availableGrades(List<Module> modules) {
    final values = modules.map((module) => module.grade).toSet().toList()
      ..sort();
    return values;
  }

  List<String> _availableSpecialities(List<Module> modules) {
    final filteredByGrade = gradeVal == null
        ? modules
        : modules.where((module) => module.grade == gradeVal).toList();
    final values = filteredByGrade
        .map((module) => module.speciality)
        .toSet()
        .toList()
      ..sort();
    return values;
  }

  double _averageAttendance(List<Module> modules) {
    if (modules.isEmpty) {
      return 0;
    }
    final total = modules.fold<double>(
      0,
      (sum, module) => sum + moduleAttendancePercentage(module),
    );
    return total / modules.length;
  }

  int _totalStudents(List<Module> modules) {
    return modules.fold<int>(
      0,
      (sum, module) => sum + moduleStudentCount(module),
    );
  }

  void _openSelectModule(Teacher teacher, List<Module> modules) {
    Navigator.pushNamed(
      context,
      '/selectModule',
      arguments: {
        'modules': modules,
        'teacher': teacher,
        'databaseService': widget.databaseService,
        'authService': widget.authService,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Teacher>(
      stream: widget.databaseService
          .getTeacherDataStream(widget.authService.currentUsr!.uid),
      builder: (context, teacherSnapshot) {
        if (teacherSnapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (teacherSnapshot.hasError) {
          return ErrorPages(
            title: 'Server Error',
            message: teacherSnapshot.error.toString(),
          );
        } else if (!teacherSnapshot.hasData) {
          return const ErrorPages(
            title: 'Error 404: Not Found',
            message: 'No module data available for teacher',
          );
        }

        final teacher = teacherSnapshot.data!;
        final moduleIds = teacher.modules ?? <String>[];

        return StreamBuilder<List<Module>>(
          stream: widget.databaseService.getModulesOfTeacher(moduleIds),
          builder: (context, modulesSnapshot) {
            if (modulesSnapshot.connectionState == ConnectionState.waiting) {
              return const Loading();
            } else if (modulesSnapshot.hasError) {
              return ErrorPages(
                title: 'Server Error',
                message: modulesSnapshot.error.toString(),
              );
            } else if (!modulesSnapshot.hasData) {
              return const Loading();
            }

            final modulesData = modulesSnapshot.data!;
            final filteredModules = _filterModules(modulesData);
            final activeModules =
                modulesData.where((module) => module.isActive).length;
            final grades = _availableGrades(modulesData);
            final specialities = _availableSpecialities(modulesData);

            return Scaffold(
              drawer: BuildDrawer(
                authService: widget.authService,
                databaseService: widget.databaseService,
                userType: 'teacher',
                teacher: teacher,
                modules: modulesData,
              ),
              body: AttendifyScreen(
                leading: Builder(
                  builder: (ctx) => GestureDetector(
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                    child: AttendifyUserAvatar(imageUrl: teacher.photoURL),
                  ),
                ),
                title: 'Managed courses',
                subtitle:
                    '${modulesData.length} assigned modules • $activeModules currently active',
                actions: [
                  IconButton(
                    tooltip: 'Log out',
                    onPressed: () => widget.authService.logout(context),
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth > 700;
                        final itemWidth = wide
                            ? (constraints.maxWidth - 24) / 3
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: AttendifySpacing.md,
                          runSpacing: AttendifySpacing.md,
                          children: [
                            SizedBox(
                              width: itemWidth,
                              child: AttendifyMetricCard(
                                label: 'Active sessions',
                                value: '$activeModules',
                                helper:
                                    '${modulesData.length - activeModules} courses are currently idle',
                                icon: Icons.play_circle_rounded,
                                emphasized: true,
                              ),
                            ),
                            SizedBox(
                              width: itemWidth,
                              child: AttendifyMetricCard(
                                label: 'Covered students',
                                value: '${_totalStudents(modulesData)}',
                                helper: 'Across your assigned module roster',
                                icon: Icons.groups_2_rounded,
                              ),
                            ),
                            SizedBox(
                              width: itemWidth,
                              child: AttendifyMetricCard(
                                label: 'Average attendance',
                                value:
                                    '${_averageAttendance(modulesData).toStringAsFixed(0)}%',
                                helper:
                                    'Calculated from historical session records',
                                icon: Icons.insights_rounded,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AttendifySpacing.lg),
                    AttendifySurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Filter your portfolio',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              if (gradeVal != null || specialityVal != null)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      gradeVal = null;
                                      specialityVal = null;
                                    });
                                  },
                                  child: const Text('Reset'),
                                ),
                            ],
                          ),
                          const SizedBox(height: AttendifySpacing.md),
                          Wrap(
                            spacing: AttendifySpacing.sm,
                            runSpacing: AttendifySpacing.sm,
                            children: [
                              ChoiceChip(
                                label: const Text('All grades'),
                                selected: gradeVal == null,
                                onSelected: (_) {
                                  setState(() {
                                    gradeVal = null;
                                    specialityVal = null;
                                  });
                                },
                              ),
                              ...grades.map(
                                (grade) => ChoiceChip(
                                  label: Text('$grade year'),
                                  selected: gradeVal == grade,
                                  onSelected: (_) {
                                    setState(() {
                                      gradeVal = grade;
                                      specialityVal = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (specialities.isNotEmpty) ...[
                            const SizedBox(height: AttendifySpacing.md),
                            Wrap(
                              spacing: AttendifySpacing.sm,
                              runSpacing: AttendifySpacing.sm,
                              children: [
                                ChoiceChip(
                                  label: const Text('All specialities'),
                                  selected: specialityVal == null,
                                  onSelected: (_) =>
                                      setState(() => specialityVal = null),
                                ),
                                ...specialities.map(
                                  (speciality) => ChoiceChip(
                                    label: Text(speciality),
                                    selected: specialityVal == speciality,
                                    onSelected: (_) {
                                      setState(
                                          () => specialityVal = speciality);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: AttendifySpacing.lg),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _openSelectModule(teacher, modulesData),
                              icon: const Icon(Icons.add_chart_rounded),
                              label: const Text('Select or add modules'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AttendifySpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            filteredModules.isEmpty && modulesData.isNotEmpty
                                ? 'No modules match the current filters'
                                : 'Course portfolio',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if (filteredModules.isNotEmpty)
                          Text(
                            '${filteredModules.length} shown',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    const SizedBox(height: AttendifySpacing.md),
                    modulesData.isEmpty
                        ? AttendifyEmptyState(
                            title: 'No assigned modules yet',
                            message:
                                'Start by selecting the courses you manage. They will appear here with session and attendance summaries.',
                            action: ElevatedButton.icon(
                              onPressed: () =>
                                  _openSelectModule(teacher, modulesData),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Select modules'),
                            ),
                          )
                        : filteredModules.isEmpty
                            ? const AttendifyEmptyState(
                                title: 'No matching courses',
                                message:
                                    'Try another grade or speciality filter to bring matching courses back into view.',
                              )
                            : ModuleListView(
                                modules: filteredModules,
                                userType: 'teacher',
                                teacher: teacher,
                                databaseService: widget.databaseService,
                                shrinkWrap: true,
                              ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
