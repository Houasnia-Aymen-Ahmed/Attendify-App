import 'package:flutter/material.dart';

import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/theme/attendify_ui.dart';

class AllStudentsView extends StatelessWidget {
  final List<Student> dataStudents;

  const AllStudentsView({
    super.key,
    required this.dataStudents,
  });

  @override
  Widget build(BuildContext context) {
    final students = [...dataStudents]
      ..sort((left, right) => left.userName.toLowerCase().compareTo(right.userName.toLowerCase()));

    if (students.isEmpty) {
      return const Center(
        child: AttendifyEmptyState(
          title: 'No students found',
          message: 'Student accounts will appear here once registration completes.',
        ),
      );
    }

    return ListView.separated(
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: AttendifySpacing.md),
      itemBuilder: (context, index) {
        final student = students[index];
        return AttendifySurface(
          child: Row(
            children: [
              AttendifyUserAvatar(imageUrl: student.photoURL),
              const SizedBox(width: AttendifySpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.userName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AttendifySpacing.xs),
                    Text(
                      student.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AttendifyPalette.mutedText,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: AttendifySpacing.sm,
                      runSpacing: AttendifySpacing.sm,
                      children: [
                        AttendifyStatusChip(
                          label: '${student.grade ?? '-'} year',
                          color: AttendifyPalette.tertiary,
                        ),
                        AttendifyStatusChip(
                          label: student.speciality ?? 'No speciality',
                          color: AttendifyPalette.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
