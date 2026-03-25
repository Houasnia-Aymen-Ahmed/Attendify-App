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
