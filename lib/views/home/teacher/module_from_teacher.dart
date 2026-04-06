import 'package:flutter/material.dart';

import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/error_pages.dart';
import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/theme/attendify_ui.dart';
import 'package:attendify/views/home/teacher/presence_table.dart';

class ModuleViewFromTeacher extends StatefulWidget {
  final Module module;
  final DatabaseService databaseService;

  const ModuleViewFromTeacher({
    super.key,
    required this.module,
    required this.databaseService,
  });

  @override
  State<ModuleViewFromTeacher> createState() => _ModuleViewFromTeacherState();
}

class _ModuleViewFromTeacherState extends State<ModuleViewFromTeacher> {
  late Stream<List<Student>> _studentsStream;
  late Stream<Module> _moduleStream;

  List<Student>? _cachedStudents;
  Module? _cachedModule;

  @override
  void initState() {
    super.initState();
    _cachedModule = widget.module;
    _studentsStream =
        widget.databaseService.getStudentsList(widget.module.students.keys.toList());
    _moduleStream = widget.databaseService.getModuleStream(widget.module.uid);
  }

  @override
  void didUpdateWidget(covariant ModuleViewFromTeacher oldWidget) {
    super.didUpdateWidget(oldWidget);

    final moduleChanged = oldWidget.module.uid != widget.module.uid;
    final rosterChanged =
        !_sameStudentIds(oldWidget.module.students.keys, widget.module.students.keys);
    final serviceChanged = oldWidget.databaseService != widget.databaseService;

    if (moduleChanged || serviceChanged) {
      _cachedModule = widget.module;
      _moduleStream = widget.databaseService.getModuleStream(widget.module.uid);
    }

    if (moduleChanged || rosterChanged || serviceChanged) {
      _studentsStream =
          widget.databaseService.getStudentsList(widget.module.students.keys.toList());
    }
  }

  bool _sameStudentIds(Iterable<String> a, Iterable<String> b) {
    final left = a.toList()..sort();
    final right = b.toList()..sort();
    if (left.length != right.length) return false;

    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }

  Widget _buildScreenShell(
    BuildContext context,
    Module module, {
    required Widget child,
  }) {
    return Scaffold(
      body: AttendifyScreen(
        leading: const Icon(
          Icons.menu_book_rounded,
          color: AttendifyPalette.primary,
        ),
        title: module.name,
        subtitle: '${module.grade} year • ${module.speciality}',
        actions: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Student>>(
      stream: _studentsStream,
      initialData: _cachedStudents,
      builder: (context, studentsSnapshot) {
        final students = studentsSnapshot.data;
        if (students != null) {
          _cachedStudents = students;
        }

        if (studentsSnapshot.hasError && students == null) {
          return ErrorPages(
            title: 'Server Error',
            message: studentsSnapshot.error.toString(),
          );
        }

        return StreamBuilder<Module>(
          stream: _moduleStream,
          initialData: _cachedModule,
          builder: (context, moduleSnapshot) {
            final refreshedModule = moduleSnapshot.data ?? _cachedModule ?? widget.module;
            _cachedModule = refreshedModule;

            if (moduleSnapshot.hasError && moduleSnapshot.data == null) {
              return ErrorPages(
                title: 'Server Error',
                message: moduleSnapshot.error.toString(),
              );
            }

            if (studentsSnapshot.hasData && students != null && students.isEmpty) {
              return const ErrorPages(
                title: 'Error 404: Not Found',
                message: 'There are no students for this module',
              );
            }

            if (students == null) {
              return _buildScreenShell(
                context,
                refreshedModule,
                child: const AttendifySurface(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      SizedBox(width: AttendifySpacing.md),
                      Expanded(
                        child: Text(
                          'Loading student roster and live session data...',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return _buildScreenShell(
              context,
              refreshedModule,
              child: PresenceTable(
                students: students,
                module: refreshedModule,
                databaseService: widget.databaseService,
              ),
            );
          },
        );
      },
    );
  }
}
