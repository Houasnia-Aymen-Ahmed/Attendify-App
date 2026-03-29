import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:attendify/components/popups.dart';
import 'package:attendify/theme/attendify_theme.dart';

class CustomCircleChart extends StatelessWidget {
  final Map<String, int> attendanceData;
  final int numberOfStudents;

  const CustomCircleChart({
    super.key,
    required this.attendanceData,
    required this.numberOfStudents,
  });

  @override
  Widget build(BuildContext context) {
    int totalPresent = attendanceData.values.reduce((a, b) => a + b);
    double percentage = totalPresent / (27 * attendanceData.length) * 100;
    return AspectRatio(
      aspectRatio: 1.6,
      child: Card(
        margin: const EdgeInsets.all(10.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: GestureDetector(
          onLongPress: () => infoTost('Percentage of attendance'),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              gradient: const LinearGradient(
                colors: [
                  AttendifyPalette.chartGradientTop,
                  AttendifyPalette.chartGradientBottom,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 20.0,
              animateFromLastPercent: true,
              animation: true,
              animationDuration: 1000,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              curve: Curves.easeInOutCubic,
              percent: percentage / 100,
              backgroundWidth: 12.5,
              center: Text(
                '${percentage.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w900,
                  color: Color.lerp(
                    AttendifyPalette.chartBar,
                    AttendifyPalette.chartBarTouched,
                    percentage / 100,
                  ),
                ),
              ),
              progressColor: Color.lerp(
                AttendifyPalette.chartLine,
                AttendifyPalette.chartBarTouched,
                percentage / 100,
              ),
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),
        ),
      ),
    );
  }
}
