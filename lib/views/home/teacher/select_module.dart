import 'package:flutter/material.dart';

import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/theme/attendify_ui.dart';

import 'package:attendify/components/custom_dropdown_btn.dart';
import 'package:attendify/components/popups.dart';
import 'package:attendify/models/attendify_teacher.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/school_data.dart';

class SelectModule extends StatefulWidget {
  final Teacher teacher;
  final List<Module>? modules;
  final DatabaseService databaseService;
  final AuthService authService;

  const SelectModule({
    super.key,
    required this.teacher,
    required this.modules,
    required this.databaseService,
    required this.authService,
  });

  @override
  State<SelectModule> createState() => _SelectModuleState();
}

class _SelectModuleState extends State<SelectModule> {
  final List<String> _addedModules = [], _selectedModules = [];
  late List<Module> _selectedModulesModel;
  String? _gradeVal, _specialityVal;
  bool _hasSelected = false, _isSaved = false, _isDisabled = true, isSaving = false;

  void _addModule(String uid, String name, String grade, String speciality, bool isActive) {
    setState(() {
      _selectedModulesModel.add(
        Module(uid: uid, grade: grade, isActive: isActive, name: name, speciality: speciality),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _isSaved = false;
    _selectedModulesModel = widget.modules ?? [];
    _selectedModules.clear();
    _selectedModules.addAll(_selectedModulesModel.map((module) => module.uid));
  }

  Future<void> _handleBack() async {
    if (_addedModules.isNotEmpty && !_isSaved) {
      await showCloseConfirmationDialog(context);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _handleSave(List<String> modules) async {
    showLoadingDialog(context, 'Saving modules ...');
    try {
      setState(() => isSaving = true);
      for (final module in _addedModules) {
        final parts = module.split('_');
        final grade = parts[0];
        final speciality = parts[1];
        final moduleIndex = int.parse(parts[3].toString().padLeft(2, '0'));
        final moduleName = modulesMap[grade]![speciality]![moduleIndex];
        await widget.databaseService.updateModuleSpecificData(
          uid: module,
          name: moduleName,
          isActive: false,
          speciality: speciality,
          grade: grade,
        );
        _addModule(module, moduleName, grade, speciality, false);
      }
      await widget.databaseService.updateTeacherSpecificData(modules: _addedModules);

      setState(() => _isSaved = true);
      if (!mounted) return;
      Navigator.of(context).pop();
      showDialogBox(context, 'Success', 'Modules saved successfully', false);
    } catch (e) {
      setState(() => isSaving = false);
      if (!mounted) return;
      Navigator.of(context).pop();
      showDialogBox(context, 'Error', 'Error saving modules: $e', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String>? modules;
    if (_gradeVal != null &&
        _specialityVal != null &&
        modulesMap.containsKey(_gradeVal) &&
        modulesMap[_gradeVal]?.containsKey(_specialityVal) == true) {
      modules = modulesMap[_gradeVal]![_specialityVal];
      if (modules != null && modules.isNotEmpty && modules[0] == '') {
        modules = null;
      }
    }

    return Scaffold(
      body: AttendifyScreen(
        scrollable: false,
        expandChild: true,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: _handleBack,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AttendifyPalette.primary,
          ),
        ),
        title: 'Select modules',
        subtitle: 'Choose the courses you want to assign to your teaching portfolio.',
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
            // ── Grade & speciality dropdowns ──────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: CustomDropdownBtn(
                    hint: 'Choose grade',
                    type: 'grade',
                    gradeVal: _gradeVal,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _isDisabled = false;
                        _gradeVal = newValue;
                        _specialityVal = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: AttendifySpacing.md),
                Expanded(
                  child: CustomDropdownBtn(
                    hint: 'Choose speciality',
                    type: 'speciality',
                    isDisabled: _isDisabled,
                    gradeVal: _gradeVal,
                    specialityVal: _specialityVal,
                    isExpanded: true,
                    onChanged: _isDisabled
                        ? null
                        : (String? newValue) => setState(() => _specialityVal = newValue),
                  ),
                ),
              ],
            ),

            // ── Selection summary banner ──────────────────────────────────────
            if (_hasSelected) ...[
              const SizedBox(height: AttendifySpacing.md),
              AttendifySurface(
                color: AttendifyPalette.surfaceMuted,
                padding: const EdgeInsets.symmetric(horizontal: AttendifySpacing.lg, vertical: AttendifySpacing.sm),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: AttendifyPalette.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_addedModules.length} new module(s) selected',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _addedModules.clear();
                        _selectedModules.clear();
                        _selectedModules.addAll(
                          _selectedModulesModel.map((m) => m.uid),
                        );
                        _hasSelected = false;
                      }),
                      icon: const Icon(Icons.undo_rounded, size: 18),
                      label: const Text('Undo'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AttendifySpacing.lg),

            // ── Module list ───────────────────────────────────────────────────
            Expanded(
              child: _gradeVal == null || _specialityVal == null
                  ? const Center(
                      child: AttendifyEmptyState(
                        title: 'Choose a grade and speciality',
                        message:
                            'Select a grade and speciality above to see the available modules for that track.',
                      ),
                    )
                  : modules == null
                      ? const Center(
                          child: AttendifyEmptyState(
                            title: 'No modules available',
                            message:
                                'There are no modules configured for the selected grade and speciality.',
                          ),
                        )
                      : ListView.separated(
                          itemCount: modules.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AttendifySpacing.sm),
                          itemBuilder: (context, index) {
                            final moduleName = modules![index];
                            final moduleId =
                                '${_gradeVal}_${_specialityVal}_module_$index';
                            final isSelected = _selectedModules.contains(moduleId);
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: AttendifyRadius.lgAll,
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _addedModules.remove(moduleId);
                                      _selectedModules.remove(moduleId);
                                    } else {
                                      _addedModules.add(moduleId);
                                      _selectedModules.add(moduleId);
                                    }
                                    _hasSelected = _addedModules.isNotEmpty;
                                  });
                                },
                                child: AttendifySurface(
                                  color: isSelected
                                      ? AttendifyPalette.primary.withValues(alpha: 0.06)
                                      : AttendifyPalette.surface,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AttendifySpacing.lg,
                                    vertical: AttendifySpacing.md,
                                  ),
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AttendifyPalette.primary
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isSelected
                                                ? AttendifyPalette.primary
                                                : AttendifyPalette.outline,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check_rounded,
                                                size: 14,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: AttendifySpacing.md),
                                      Expanded(
                                        child: Text(
                                          moduleName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: isSelected
                                                    ? AttendifyPalette.primary
                                                    : AttendifyPalette.text,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),

            const SizedBox(height: AttendifySpacing.lg),

            // ── Action buttons ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleBack,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AttendifySpacing.md),
                Expanded(
                  child: AttendifyPrimaryButton(
                    label: 'Save modules',
                    icon: Icons.check_rounded,
                    isLoading: isSaving,
                    onPressed: _addedModules.isEmpty || modules == null
                        ? null
                        : () => _handleSave(modules!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
