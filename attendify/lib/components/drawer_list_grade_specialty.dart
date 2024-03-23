import 'package:flutter/material.dart';

import '../utils/functions.dart';

class DrawerListGradeSpecialty extends StatelessWidget {
  final dynamic user;
  const DrawerListGradeSpecialty({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: drawerList(user),
    );
  }

  List<ListTile> drawerList(dynamic user) {
    return [
      ListTile(
        title: Text(
          capitalizeFirst(user?.grade ?? "Grade"),
        ),
        subtitle: const Text("Grade"),
      ),
      ListTile(
        title: Text(
          capitalizeFirst(user?.speciality ?? "Speciality"),
        ),
        subtitle: const Text("Speciality"),
      ),
    ];
  }
}
