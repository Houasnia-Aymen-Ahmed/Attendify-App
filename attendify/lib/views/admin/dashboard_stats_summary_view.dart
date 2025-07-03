import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminDashboardStatsSummaryView extends StatelessWidget {
  final int totalModules;
  final int activeModules;
  final int inactiveModules;
  final int totalTeachers;
  final int totalStudents;

  const AdminDashboardStatsSummaryView({
    super.key,
    required this.totalModules,
    required this.activeModules,
    required this.inactiveModules,
    required this.totalTeachers,
    required this.totalStudents,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, "Overall Statistics"),
            const SizedBox(height: 12.0),
            _buildStatRow(context, FontAwesomeIcons.bookOpenReader, "Total Modules:", totalModules.toString()),
            _buildStatRow(context, FontAwesomeIcons.checkCircle, "Active Modules:", activeModules.toString(), indent: true),
            _buildStatRow(context, FontAwesomeIcons.timesCircle, "Inactive Modules:", inactiveModules.toString(), indent: true),
            const SizedBox(height: 10.0),
            _buildStatRow(context, FontAwesomeIcons.personChalkboard, "Total Teachers:", totalTeachers.toString()),
            const SizedBox(height: 10.0),
            _buildStatRow(context, FontAwesomeIcons.graduationCap, "Total Students:", totalStudents.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue[700]),
    );
  }

  Widget _buildStatRow(BuildContext context, IconData icon, String label, String value, {bool indent = false}) {
    return Padding(
      padding: EdgeInsets.only(left: indent ? 16.0 : 0, top: 4.0, bottom: 4.0),
      child: Row(
        children: [
          FaIcon(icon, size: 18.0, color: Colors.blue[600]),
          const SizedBox(width: 10.0),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8.0),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
