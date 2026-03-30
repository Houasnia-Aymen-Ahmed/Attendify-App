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
    final int totalPresent =
        attendanceData.values.fold(0, (sum, value) => sum + value);
    final int totalSlots = numberOfStudents * attendanceData.length;
    final double percentage =
        totalSlots > 0 ? (totalPresent / totalSlots) * 100 : 0;
    final double normalizedPercentage =
        (percentage / 100).clamp(0.0, 1.0).toDouble();
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
              percent: normalizedPercentage,
              backgroundWidth: 12.5,
              center: Text(
                '${percentage.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w900,
                  color: Color.lerp(
                    AttendifyPalette.chartBar,
                    AttendifyPalette.chartBarTouched,
                    normalizedPercentage,
                  ),
                ),
              ),
              progressColor: Color.lerp(
                AttendifyPalette.chartLine,
                AttendifyPalette.chartBarTouched,
                normalizedPercentage,
              ),
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),
        ),
      ),
    );
  }
}
