import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../components/popups.dart';

class LineData {
  List<MapEntry<String, int>> sortedEntries;
  int maxVal;
  LineData({
    required this.sortedEntries,
    required this.maxVal,
  });
}

class CustomLineChart extends StatelessWidget {
  final LineData charts;
  const CustomLineChart({super.key, required this.charts});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: Card(
        margin: const EdgeInsets.all(10.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: GestureDetector(
          onLongPress: () => infoTost("Number of students each session"),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade100,
                  Colors.deepPurple.shade300,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 500,
                  height: 200,
                  child: LineChart(
                    sampleData(charts),
                    curve: Curves.easeInOutCubic,
                    duration: const Duration(milliseconds: 250),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

LineChartData sampleData(LineData charts) {
  return LineChartData(
    lineTouchData: const LineTouchData(enabled: true),
    gridData: const FlGridData(show: true),
    titlesData: titlesData(charts.sortedEntries, charts.maxVal),
    borderData: borderData,
    lineBarsData: [lineChartBarData(charts.sortedEntries)],
    minX: 0,
    maxX: charts.sortedEntries.length.toDouble(),
    maxY: 4,
    minY: 0,
  );
}

FlTitlesData titlesData(
        List<MapEntry<String, int>> sortedEntries, int maxVal) =>
    FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: bottomTitles(sortedEntries),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: leftTitles(maxVal),
      ),
    );

Widget leftTitleWidgets(double value, TitleMeta meta, {required int maxVal}) {
  const style = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  int index;

  if (maxVal < 40) {
    index = (value * 2).toInt();
  } else if (maxVal < 70) {
    index = (value * 4).toInt();
  } else {
    index = (value * 12).toInt();
  }

  String text = (index * 5).toString();

  return Text(text, style: style, textAlign: TextAlign.center);
}

SideTitles leftTitles(int maxVal) => SideTitles(
      getTitlesWidget: (double value, TitleMeta meta) => leftTitleWidgets(
        value,
        meta,
        maxVal: maxVal,
      ),
      showTitles: true,
      interval: 0.5,
    );

Widget bottomTitleWidgets(
  double value,
  TitleMeta meta, {
  required List<MapEntry<String, int>> sortedEntries,
}) {
  const style = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  String text;
  int index = ((value - 0.5) * 2).toInt();

  if (index >= 0 && index < sortedEntries.length) {
    text = DateFormat('dd-MM-yy')
        .format(DateFormat("dd-MM-yy").parse(sortedEntries[index].key));
  } else {
    text = '';
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 10,
    child: Text(text, style: style),
  );
}

SideTitles bottomTitles(List<MapEntry<String, int>> sortedEntries) =>
    SideTitles(
      showTitles: true,
      reservedSize: 30,
      interval: 0.5,
      getTitlesWidget: (double value, TitleMeta meta) => bottomTitleWidgets(
        value,
        meta,
        sortedEntries: sortedEntries,
      ),
    );

FlBorderData get borderData => FlBorderData(
      show: true,
      border: Border(
        bottom: BorderSide(
          color: Colors.deepPurple[900]!,
          width: 4,
        ),
      ),
    );

List<FlSpot> chartData(
  List<MapEntry<String, int>> sortedEntries,
) =>
    List.generate(
      sortedEntries.length,
      (index) => FlSpot(
        (index / 2 + 0.5).toDouble(),
        (sortedEntries[index].value / 10).toDouble(),
      ),
    );

LineChartBarData lineChartBarData(
  List<MapEntry<String, int>> sortedEntries,
) =>
    LineChartBarData(
      isCurved: true,
      color: Colors.deepPurple,
      barWidth: 2,
      preventCurveOverShooting: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: Colors.white.withOpacity(0.3),
      ),
      spots: chartData(sortedEntries),
    );
