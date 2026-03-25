import 'package:attendify/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/attendify_student.dart';
import '../../../shared/error_pages.dart';
import '../../../shared/loading.dart';
import '../body.dart';
import '../drawer.dart';

class StudentView extends ConsumerWidget {
  final Student student;
  const StudentView({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final databaseService = ref.watch(databaseServiceProvider);
    final studentAsyncValue = ref.watch(studentProvider(authService.currentUsr!.uid));

    return studentAsyncValue.when(
      data: (student) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Attendify"),
            backgroundColor: Colors.blue[200],
            actions: [
              IconButton(
                onPressed: () {
                  authService.logout();
                },
                icon: const Icon(Icons.logout_rounded),
              )
            ],
          ),
          drawer: BuildDrawer(
            student: student,
            authService: authService,
            databaseService: databaseService,
            userType: "student",
          ),
          body: BuildBody(
            student: student,
            databaseService: databaseService,
            authService: authService,
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
