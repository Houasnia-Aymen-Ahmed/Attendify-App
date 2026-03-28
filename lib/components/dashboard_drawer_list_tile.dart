import 'package:flutter/material.dart';

import '../theme/attendify_theme.dart';

class DashboardDrawerListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongTap;

  const DashboardDrawerListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    this.onTap,
    this.onLongTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 6.0,
      ),
      child: ListTile(
        horizontalTitleGap: 20.0,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 25.0,
          vertical: 8.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        splashColor: AttendifyPalette.primaryStrong,
        tileColor: selected ? AttendifyPalette.primary : AttendifyPalette.surfaceMuted,
        leading: Icon(
          icon,
          color: selected ? Colors.white : AttendifyPalette.text,
          size: 30,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 19,
            color: selected ? Colors.white : AttendifyPalette.text,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: selected
                ? Colors.white.withValues(alpha: 0.6)
                : AttendifyPalette.mutedText,
          ),
        ),
        onTap: onTap,
        onLongPress: onLongTap,
      ),
    );
  }
}
