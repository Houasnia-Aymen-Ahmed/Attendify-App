import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../theme/attendify_theme.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AttendifyPalette.background,
            Color(0xFFEAF1F8),
          ],
        ),
      ),
      child: Center(
        child: SpinKitWaveSpinner(
          curve: Curves.linear,
          trackColor: AttendifyPalette.surfaceStrong,
          waveColor: AttendifyPalette.secondary.withValues(alpha: 0.75),
          color: AttendifyPalette.primary,
          size: 110.0,
        ),
      ),
    );
  }
}
