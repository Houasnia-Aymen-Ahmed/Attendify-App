import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../components/popups.dart';

class CustomBarChart extends StatefulWidget {
  final Map<String, double> data;
  final String itemType;
  final int? numberOfStudents;
  const CustomBarChart({
    super.key,
    required this.data,
    required this.itemType,
    this.numberOfStudents,
  });

  @override
  State<StatefulWidget> createState() => CustomBarChartState();
}

class CustomBarChartState extends State<CustomBarChart> {
  int touchedIndex = -1;
  final double maxPercentage = 100;
  final Color barBackgroundColor = Colors.white.withOpacity(0.3);
  final Color barColor = Colors.deepPurple.shade300;
  final Color touchedBarColor = Colors.deepPurple.shade900;
  late List<String> names;
  late List<double> values;
  @override
  void initState() {
    super.initState();
    names = widget.data.keys.toList();
    values = widget.data.values.toList();
  }

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
          onLongPress: () =>
              infoTost("Percentage of each ${widget.itemType}'s attendance"),
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: names.length * 90.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 16.0,
                  ),
                  child: BarChart(
                    mainBarData(values, names),
                    swapAnimationCurve: Curves.easeInOutCubic,
                    swapAnimationDuration: const Duration(milliseconds: 250),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    double width = 25,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched
              ? touchedBarColor
              : Color.lerp(
                  barColor,
                  touchedBarColor,
                  y / maxPercentage,
                ),
          width: width,
          borderSide: isTouched
              ? BorderSide(color: Colors.deepPurple.shade300)
              : const BorderSide(width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxPercentage,
            color: barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups(
    List<double> values,
    List<String> names,
  ) {
    return List.generate(
      names.length,
      (i) {
        return makeGroupData(
          i,
          values[i],
          isTouched: i == touchedIndex,
        );
      },
    );
  }

  BarChartData mainBarData(
    List<double> values,
    List<String> names,
  ) {
    return BarChartData(
      alignment: BarChartAlignment.spaceEvenly,
      maxY: maxPercentage,
      minY: 0,
      baselineY: 0,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.deepPurple.shade300,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipRoundedRadius: 10,
          tooltipMargin: -10,
          tooltipPadding: const EdgeInsets.all(5.0),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${names[group.x]}\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: "${(rod.toY - 1).toStringAsFixed(2)}%",
                  style: TextStyle(
                    color: touchedBarColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) => getTitles(
              value,
              meta,
              names: names,
            ),
            reservedSize: 45,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(values, names),
      gridData: const FlGridData(show: false),
    );
  }

  Widget getTitles(
    double value,
    TitleMeta meta, {
    required List<String> names,
  }) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    final List<String> splitedNames = names.map((names) {
      return names.split(" ").join('\n');
    }).toList();
    if (value.toInt() >= 0 && value.toInt() < splitedNames.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 1,
        child: Text(
          splitedNames[value.toInt()],
          style: style,
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 16,
        child: const Text('s', style: style),
      );
    }
  }
}
