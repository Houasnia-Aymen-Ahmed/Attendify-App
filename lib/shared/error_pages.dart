import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorPages extends StatelessWidget {
  final String title;
  final String message;
  const ErrorPages({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 30,
            ),
          ),
        ),
      ),
    );
  }
}
