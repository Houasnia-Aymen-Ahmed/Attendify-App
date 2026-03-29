import 'package:flutter/material.dart';

import 'package:attendify/components/popups.dart';
import 'package:attendify/models/attendify_teacher.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/theme/attendify_ui.dart';

class AllTeachersView extends StatefulWidget {
  final Map<String, dynamic> dataTeachers;
  final DatabaseService databaseService;

  const AllTeachersView({
    super.key,
    required this.dataTeachers,
    required this.databaseService,
  });

  @override
  State<AllTeachersView> createState() => _AllTeachersViewState();
}

class _AllTeachersViewState extends State<AllTeachersView> {
  bool showEmails = false;

  List<Teacher> get _teachers =>
      (widget.dataTeachers['teachers'] as List<Teacher>)
        ..sort((left, right) => left.userName.toLowerCase().compareTo(right.userName.toLowerCase()));

  List<String> get _emails =>
      (widget.dataTeachers['emails'] as List<String>)
        ..sort((left, right) => left.toLowerCase().compareTo(right.toLowerCase()));

  @override
  Widget build(BuildContext context) {
    final teachers = _teachers;
    final emails = _emails;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AttendifySurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Faculty management',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Teachers'),
                    selected: !showEmails,
                    onSelected: (_) => setState(() => showEmails = false),
                  ),
                  ChoiceChip(
                    label: const Text('Whitelisted emails'),
                    selected: showEmails,
                    onSelected: (_) => setState(() => showEmails = true),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: showEmails
              ? emails.isEmpty
                  ? const Center(
                      child: AttendifyEmptyState(
                        title: 'No teacher emails',
                        message:
                            'Add a teacher email from the overview actions to allow a new staff member to register.',
                      ),
                    )
                  : ListView.separated(
                      itemCount: emails.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final email = emails[index];
                        return AttendifySurface(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified_user_rounded,
                                color: AttendifyPalette.secondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      email,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Whitelisted for teacher registration',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AttendifyPalette.mutedText,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove email',
                                onPressed: () {
                                  removeConfirmationDialog(
                                    context,
                                    'email',
                                    () => widget.databaseService.removeTeacherEmail(email),
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AttendifyPalette.error,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
              : teachers.isEmpty
                  ? const Center(
                      child: AttendifyEmptyState(
                        title: 'No teachers yet',
                        message:
                            'Once teachers register with an approved email, they will appear here for review.',
                      ),
                    )
                  : ListView.separated(
                      itemCount: teachers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final teacher = teachers[index];
                        final assignedModules = teacher.modules?.length ?? 0;
                        return AttendifySurface(
                          child: Row(
                            children: [
                              AttendifyUserAvatar(imageUrl: teacher.photoURL),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      teacher.userName,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      teacher.email,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AttendifyPalette.mutedText,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    AttendifyStatusChip(
                                      label: '$assignedModules assigned modules',
                                      color: AttendifyPalette.secondary,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove teacher',
                                onPressed: () {
                                  removeConfirmationDialog(
                                    context,
                                    'teacher',
                                    () => widget.databaseService
                                        .removeTeacherById(teacher.uid),
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AttendifyPalette.error,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
