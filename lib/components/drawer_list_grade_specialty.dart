import 'package:flutter/material.dart';

import 'package:attendify/utils/functions.dart';
import 'package:attendify/models/attendify_student.dart';

class DrawerListGradeSpecialty extends StatelessWidget {
  final Student? user;
  const DrawerListGradeSpecialty({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: drawerList(user),
    );
  }

  List<ListTile> drawerList(Student? user) {
    return [
      ListTile(
        title: Text(
          capitalizeFirst(user?.grade ?? 'Grade'),
        ),
        subtitle: const Text('Grade'),
      ),
      ListTile(
        title: Text(
          capitalizeFirst(user?.speciality ?? 'Speciality'),
        ),
        subtitle: const Text('Speciality'),
      ),
    ];
  }
}
