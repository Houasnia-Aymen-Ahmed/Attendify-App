import 'package:attendify/services/providers.dart';
import 'package:attendify/views/statistics/charts/circle_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/loading.dart';
import 'charts/bar_chart.dart';
import 'charts/line_chart.dart';

class ModuleStats extends ConsumerWidget {
  final String moduleId;

  const ModuleStats({
    super.key,
    required this.moduleId,
  });

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
  Widget build(BuildContext context, WidgetRef ref) {
    final moduleAsyncValue = ref.watch(moduleProvider(moduleId));
    return moduleAsyncValue.when(
      data: (module) {
        final moduleStatsAsyncValue = ref.watch(moduleStatsProvider(moduleId));
        return moduleStatsAsyncValue.when(
          data: (moduleStat) {
            final Map<String, int> attendanceData = moduleStat['attendanceData']!;
            final Map<String, double> studentPresenceCount = {
              for (var entry in moduleStat['studentPresenceCount'].entries)
                if (module.students.containsKey(entry.key))
                  module.students[entry.key]!: entry.value
            };

            return Scaffold(
              appBar: AppBar(
                title: Text(module.name),
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  ref.refresh(moduleStatsProvider(moduleId));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomLineChart(charts: getAttendanceChart(attendanceData)),
                      CustomCircleChart(
                        attendanceData: attendanceData,
                        numberOfStudents: module.numberOfStudents,
                      ),
                      CustomBarChart(
                        data: studentPresenceCount,
                        itemType: 'students',
                        numberOfStudents: module.numberOfStudents,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text(error.toString())),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(error.toString())),
    );
  }
}
