import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/dashboard_drawer_list_tile.dart';
import '../theme/attendify_theme.dart';

TextStyle txt() => GoogleFonts.inter(
      color: AttendifyPalette.primary,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );

final textInputDecoration = InputDecoration(
  hintText: 'Module Name',
  hintStyle: GoogleFonts.inter(
    fontSize: 14,
    color: AttendifyPalette.mutedText,
  ),
  filled: true,
  border: outLineBorder(),
  enabledBorder: outLineBorder(),
  focusedBorder: outLineBorder(),
);

var dropDownTextStyle = GoogleFonts.inter(
  color: AttendifyPalette.text,
  fontSize: 15,
  fontWeight: FontWeight.w600,
);

OutlineInputBorder outLineBorder() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: AttendifyPalette.outline,
        width: 1.0,
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
