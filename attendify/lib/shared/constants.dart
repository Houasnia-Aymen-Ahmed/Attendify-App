import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/dashboard_drawer_list_tile.dart';

TextStyle txt() => GoogleFonts.poppins(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.bold,
    );

final textInputDecoration = InputDecoration(
  hintText: 'Module Name',
  hintStyle: GoogleFonts.poppins(
    fontSize: 15,
    color: Colors.black38,
  ),
  filled: true,
  border: outLineBorder(),
  enabledBorder: outLineBorder(),
  focusedBorder: outLineBorder(),
);

var dropDownTextStyle = GoogleFonts.poppins(
  color: Colors.black,
  fontSize: 15,
  fontWeight: FontWeight.w500,
);

String capitalizeFirst(String input) {
  if (input.length <= 1) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}

String? capitalizeWords(String? input) {
  if (input == null || input.isEmpty) {
    return input;
  }

  List<String> words = input.split(' ');

  for (int i = 0; i < words.length; i++) {
    if (words[i].isNotEmpty) {
      words[i] =
          words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
    }
  }

  return words.join(' ');
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

Padding imageItem(IconData icon) {
  return Padding(
    padding: const EdgeInsets.all(15.0),
    child: Icon(
      icon,
      color: Colors.blue[100],
      size: 25,
    ),
  );
}

OutlineInputBorder outLineBorder() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: Colors.blue[900]!,
        width: 1.0,
        style: BorderStyle.solid,
      ),
    );

List<Widget> dashboardDrawerList({
  required BuildContext context,
  required int selectedIndex,
  required Function(int) onTap,
  Function(int)? onLongTap,
}) {
  return [
    DashboardDrawerListTile(
      title: 'Modules',
      subtitle: 'Add new modules',
      icon: FontAwesomeIcons.bookOpenReader,
      selected: selectedIndex == 0,
      onTap: () => onTap(0),
    ),
    DashboardDrawerListTile(
      title: 'Teachers',
      subtitle: 'Add new teachers',
      icon: FontAwesomeIcons.personChalkboard,
      selected: selectedIndex == 1,
      onTap: () => onTap(1),
    ),
    DashboardDrawerListTile(
      title: 'Settings',
      subtitle: 'Open settings',
      icon: FontAwesomeIcons.gears,
      selected: selectedIndex == 2,
      onTap: () => onTap(2),
    ),
  ];
}
