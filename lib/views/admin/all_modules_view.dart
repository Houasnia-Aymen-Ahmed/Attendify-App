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
        : widget.dataModules.where((module) => module.grade == gradeVal).toList();
    return source.map((module) => module.speciality).toSet().toList()..sort();
  }

  List<Module> get _filteredModules {
    return widget.dataModules.where((module) {
      final gradeMatches = gradeVal == null || module.grade == gradeVal;
      final specialityMatches =
          specialityVal == null || module.speciality == specialityVal;
      return gradeMatches && specialityMatches;
    }).toList()
      ..sort((left, right) => left.name.toLowerCase().compareTo(right.name.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    final modules = _filteredModules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AttendifySurface(
          child: SingleChildScrollView(
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
                      child: const Text('Clear filters'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
              if (_specialities.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All specialities'),
                      selected: specialityVal == null,
                      onSelected: (_) => setState(() => specialityVal = null),
                    ),
                    ..._specialities.map(
                      (speciality) => ChoiceChip(
                        label: Text(speciality),
                        selected: specialityVal == speciality,
                        onSelected: (_) =>
                            setState(() => specialityVal = speciality),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          ),
        ),
        const SizedBox(height: 16),
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
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          module.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${module.grade} year • ${module.speciality}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AttendifyPalette.mutedText,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  AttendifyStatusChip(
                                    label: module.isActive ? 'Active' : 'Inactive',
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
                                    child: _ModuleInfoTile(
                                      label: 'Students',
                                      value: '${moduleStudentCount(module)}',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
