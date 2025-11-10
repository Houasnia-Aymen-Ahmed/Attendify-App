import 'package:attendify/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/attendify_student.dart';
import '../../../models/module_model.dart';
import '../../../shared/error_pages.dart';
import '../../../shared/loading.dart';
import 'presence_table.dart';

class ModuleViewFromTeacher extends ConsumerWidget {
  final Module module;
  const ModuleViewFromTeacher({
    super.key,
    required this.module,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsyncValue = ref.watch(studentsProvider(module.students.keys.toList()));
    return studentsAsyncValue.when(
      data: (students) {
        if (students.isEmpty) {
          return const ErrorPages(
            title: "Error 404: Not Found",
            message: "There are no students for this module",
          );
        }
        final moduleAsyncValue = ref.watch(moduleProvider(module.uid));
        return moduleAsyncValue.when(
          data: (module) {
            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    Text(
                      module.name,
                      style: const TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Icon(
                        Icons.circle_rounded,
                        size: 15,
                        color: module.isActive
                            ? Colors.green
                            : Colors
                                .red,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.blue[200],
              ),
              body: PresenceTable(
                students: students,
                module: module,
              ),
            );
          },
          loading: () => const Loading(),
          error: (error, stack) => ErrorPages(
            title: "Server Error",
            message: error.toString(),
          ),
        );
      },
      loading: () => const Loading(),
      error: (error, stack) => ErrorPages(
        title: "Server Error",
        message: error.toString(),
      ),
    );
  }
}
