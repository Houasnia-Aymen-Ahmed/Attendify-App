import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../components/popups.dart';
import '../../../theme/attendify_theme.dart';

class CustomPieChart extends StatefulWidget {
  final Map<double, List<String>> data;
  const CustomPieChart({super.key, required this.data});

  @override
  State<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> {
  int touchedIndex = -1;
  late List<double> keys;
  late int length;
  late final Iterable<MapEntry<double, List<String>>> entries;

  @override
  void initState() {
    super.initState();
    entries = widget.data.entries;
    keys = widget.data.keys.toList();
    length = entries.length;
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
          onLongPress: () => infoTost("Presence rate for each module"),
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
            child: Row(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 05,
                      centerSpaceRadius: 30,
                      sections: showingSections(),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  verticalDirection: VerticalDirection.up,
                  children: getIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Column> getIndicator() {
    return entries.map((entry) {
      final tempIndex = keys.indexOf(entry.key);
      return Column(
        children: entry.value.map((module) {
          return Indicator(
            color: getColor(tempIndex),
            text: module,
            isSquare: true,
          );
        }).toList(),
      );
    }).toList();
  }

  List<PieChartSectionData> showingSections() {
    return entries.map((entry) {
      final tempIndex = keys.indexOf(entry.key);
      final isTouched = tempIndex == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      return PieChartSectionData(
        color: getColor(tempIndex),
        value: entry.key,
        title: isTouched
            ? '${entry.key.toStringAsFixed(2)}%'
            : entry.key == keys.first
                ? 'Highest Rate'
                : 'Lowest Rate',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    }).toList();
  }

  Color getColor(int index) {
    const colors = [
      AttendifyPalette.chartBar,
      AttendifyPalette.chartLine,
      AttendifyPalette.chartBarTouched,
      AttendifyPalette.secondary,
    ];
    return colors[index % colors.length];
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
