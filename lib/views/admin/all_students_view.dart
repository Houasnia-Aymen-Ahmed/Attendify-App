import 'package:flutter/material.dart';

import '../../models/attendify_student.dart';
import '../../theme/attendify_theme.dart';
import '../../theme/attendify_ui.dart';

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
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final student = students[index];
        return AttendifySurface(
          child: Row(
            children: [
              AttendifyUserAvatar(imageUrl: student.photoURL),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.userName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AttendifyPalette.mutedText,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
