import 'package:flutter/material.dart';

import 'package:attendify/theme/attendify_theme.dart';

class DrawerFooter extends StatelessWidget {
  const DrawerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'Houasnia-Aymen-Ahmed\n© 2023-${DateTime.now().year} All rights reserved',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AttendifyPalette.mutedText,
          ),
        ),
      ),
    );
  }
}
