import 'package:flutter/material.dart';

import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/theme/attendify_ui.dart';

class ErrorPages extends StatelessWidget {
  final String title;
  final String message;
  const ErrorPages({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: AttendifyEmptyState(
            title: title,
            message: message,
            action: TextButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go back'),
              style: TextButton.styleFrom(
                foregroundColor: AttendifyPalette.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
