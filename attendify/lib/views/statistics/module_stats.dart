import 'package:attendify/views/statistics/charts/circle_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/databases.dart';
import '../../shared/loading.dart';
import 'charts/bar_chart.dart';
import 'charts/line_chart.dart';

class ModuleStats extends StatefulWidget {
  final String moduleId;
  final String moduleName;
  final Map<String, String> students;
  final int numberOfStudents;

  const ModuleStats({
    super.key,
    required this.moduleId,
    required this.numberOfStudents,
    required this.students,
    required this.moduleName,
  });

  @override
  State<ModuleStats> createState() => _ModuleStatsState();
}

class _ModuleStatsState extends State<ModuleStats> {
  final DatabaseService databaseService = DatabaseService();

  LineData getAttendanceChart(Map<String, int> attendanceData) {
    List<MapEntry<String, int>> sortedEntries = attendanceData.entries.toList()
      ..sort((a, b) => DateFormat('dd-MM-yyyy')
          .parse(a.key)
          .compareTo(DateFormat('dd-MM-yyyy').parse(b.key)));

    int maxVal = attendanceData.values.reduce(
      (max, value) => max > value ? max : value,
    );

    return LineData(
      sortedEntries: sortedEntries,
      maxVal: maxVal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseService.fetchModuleStats(widget.moduleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final moduleStat = snapshot.data!;
          final Map<String, int> attendanceData = moduleStat['attendanceData']!;
          final Map<String, double> studentPresenceCount = {
            for (var entry in moduleStat['studentPresenceCount'].entries)
              if (widget.students.containsKey(entry.key))
                widget.students[entry.key]!: entry.value
          };

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.moduleName),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomLineChart(charts: getAttendanceChart(attendanceData)),
                    CustomCircleChart(
                      attendanceData: attendanceData,
                      numberOfStudents: widget.numberOfStudents,
                    ),
                    CustomBarChart(
                      data: studentPresenceCount,
                      itemType: 'students',
                      numberOfStudents: widget.numberOfStudents,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
