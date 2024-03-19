import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../shared/constants.dart';

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
          onLongPress: () => infoTost("Percentage of attendance"),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade100,
                  Colors.deepPurple.shade300,
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
              backgroundColor: Colors.white.withOpacity(0.3),
              curve: Curves.easeInOutCubic,
              percent: percentage / 100,
              backgroundWidth: 12.5,
              center: Text(
                "${percentage.toStringAsFixed(2)}%",
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w900,
                  color: Color.lerp(
                    Colors.deepPurple.shade300,
                    Colors.deepPurple.shade900,
                    percentage / 100,
                  ),
                ),
              ),
              progressColor: Color.lerp(
                Colors.deepPurple.shade200,
                Colors.deepPurple.shade900,
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
