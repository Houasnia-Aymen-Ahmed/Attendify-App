import 'package:flutter/material.dart';

import 'package:attendify/models/module_model.dart';
import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/theme/attendify_ui.dart';
import 'package:attendify/utils/module_metrics.dart';
import 'package:attendify/views/statistics/module_stats.dart';

class AllModulesView extends StatefulWidget {
  final List<Module> dataModules;

  const AllModulesView({
    super.key,
    required this.dataModules,
  });

  @override
  State<AllModulesView> createState() => _AllModulesViewState();
}

class _AllModulesViewState extends State<AllModulesView> {
  String? gradeVal;
  String? specialityVal;

  List<String> get _grades =>
      widget.dataModules.map((module) => module.grade).toSet().toList()..sort();

  List<String> get _specialities {
    final source = gradeVal == null
        ? widget.dataModules
        : widget.dataModules
            .where((module) => module.grade == gradeVal)
            .toList();
    return source.map((module) => module.speciality).toSet().toList()..sort();
  }

  List<Module> get _filteredModules {
    return widget.dataModules.where((module) {
      final gradeMatches = gradeVal == null || module.grade == gradeVal;
      final specialityMatches =
          specialityVal == null || module.speciality == specialityVal;
      return gradeMatches && specialityMatches;
    }).toList()
      ..sort((left, right) =>
          left.name.toLowerCase().compareTo(right.name.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    final modules = _filteredModules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Compact filter bar ────────────────────────────────────────────
        AttendifySurface(
          padding: const EdgeInsets.symmetric(horizontal: AttendifySpacing.lg, vertical: AttendifySpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Academic catalogue',
                      style: Theme.of(context).textTheme.titleMedium,
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
                      child: const Text('Clear'),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Grade chips — horizontal scroll, single row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
                    ..._grades.map(
                      (grade) => Padding(
                        padding: const EdgeInsets.only(left: AttendifySpacing.sm),
                        child: ChoiceChip(
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
                    ),
                  ],
                ),
              ),
              if (_specialities.isNotEmpty) ...[
                const SizedBox(height: AttendifySpacing.sm),
                // Speciality chips — horizontal scroll, single row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All specialities'),
                        selected: specialityVal == null,
                        onSelected: (_) =>
                            setState(() => specialityVal = null),
                      ),
                      ..._specialities.map(
                        (speciality) => Padding(
                          padding: const EdgeInsets.only(left: AttendifySpacing.sm),
                          child: ChoiceChip(
                            label: Text(speciality),
                            selected: specialityVal == speciality,
                            onSelected: (_) =>
                                setState(() => specialityVal = speciality),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AttendifySpacing.md),

        // ── Module list ───────────────────────────────────────────────────
        Expanded(
          child: modules.isEmpty
              ? const Center(
                  child: AttendifyEmptyState(
                    title: 'No matching modules',
                    message:
                        'Try another grade or speciality filter to surface the relevant academic catalogue.',
                  ),
                )
              : ListView.separated(
                  itemCount: modules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AttendifySpacing.md),
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: AttendifyRadius.lgAll,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => ModuleStats(
                                moduleId: module.uid,
                                moduleName: module.name,
                                students: module.students,
                                numberOfStudents: module.numberOfStudents,
                              ),
                            ),
                          );
                        },
                        child: AttendifySurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          module.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        const SizedBox(height: AttendifySpacing.sm),
                                        Text(
                                          '${module.grade} year • ${module.speciality}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color:
                                                    AttendifyPalette.mutedText,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AttendifySpacing.md),
                                  AttendifyStatusChip(
                                    label: module.isActive
                                        ? 'Active'
                                        : 'Inactive',
                                    color: module.isActive
                                        ? AttendifyPalette.secondary
                                        : AttendifyPalette.error,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AttendifySpacing.lg),
                              Row(
                                children: [
                                  Expanded(
                                    child: _ModuleInfoTile(
                                      label: 'Students',
                                      value:
                                          '${moduleStudentCount(module)}',
                                    ),
                                  ),
                                  const SizedBox(width: AttendifySpacing.md),
                                  Expanded(
                                    child: _ModuleInfoTile(
                                      label: 'Attendance',
                                      value:
                                          '${moduleAttendancePercentage(module).toStringAsFixed(0)}%',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ModuleInfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _ModuleInfoTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AttendifySpacing.md, vertical: AttendifySpacing.md),
      decoration: const BoxDecoration(
        color: AttendifyPalette.surfaceMuted,
        borderRadius: AttendifyRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
