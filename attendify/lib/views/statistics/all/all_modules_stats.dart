import 'package:flutter/material.dart';

import '../../../utils/calculate_stats.dart';
import '../charts/bar_chart.dart';
import '../charts/pie_chart.dart';

class AllModulesStats extends StatefulWidget {
  const AllModulesStats({super.key});

  @override
  State<AllModulesStats> createState() => _AllModulesStatsState();
}

class _AllModulesStatsState extends State<AllModulesStats> {
  late Map<String, double> charts;
  late Map<double, List<String>> data;

  @override
  void initState() {
    super.initState();
    charts = CalculateStats.calculateAttendanceRate();
    data = CalculateStats.identifyhHighestAndLowestModule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All modules Stats"),
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
              CustomBarChart(
                data: charts,
                itemType: 'module',
              ),
              CustomBarChart(
                data: charts,
                itemType: 'module',
              ),
              CustomPieChart(data: data),
            ],
          ),
        ),
      ),
    );
  }
}
