import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/attendify_student.dart';
import '../../../models/module_model.dart';
import '../../../services/databases.dart';
import '../../../shared/error_pages.dart';
import '../../../shared/loading.dart';

class ModuleViewFromStudent extends StatefulWidget {
  final Module module;
  final Student student;
  const ModuleViewFromStudent({
    super.key,
    required this.module,
    required this.student,
  });

  @override
  State<ModuleViewFromStudent> createState() => _ModuleViewFromStudentState();
}

class _ModuleViewFromStudentState extends State<ModuleViewFromStudent> {
  final DatabaseService _databaseService = DatabaseService();
  String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool _isSelected = false;

  void _handleRadioValueChanged(
      String moduleID, String studentID, BuildContext context) {
    setState(() {
      _isSelected = true;
    });
    _databaseService.updateAttendance(moduleID, date, studentID, true, context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Module>(
      stream: _databaseService.getModuleStream(widget.module.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (!snapshot.hasData) {
          return ErrorPages(
            title: "Server Error",
            message: snapshot.error.toString(),
          );
        } else {
          Module module = snapshot.data!;
          Map<String, dynamic> attendanceTable = module.attendanceTable;
          List<DataRow> rows = [];
          attendanceTable.forEach((date, attendance) {
            bool? studentAttendanceValue = attendance[widget.student.uid];
            if (studentAttendanceValue == null) return;
            rows.add(DataRow(
              cells: [
                DataCell(Text(date)),
                DataCell(Text(studentAttendanceValue ? "Present" : "Absent")),
              ],
            ));
          });
          _isSelected =
              module.attendanceTable[date]?[widget.student.uid] ?? false;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                module.name,
                style: const TextStyle(
                  fontSize: 17.5,
                ),
              ),
              backgroundColor: Colors.blue[200],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Confirm presence",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      Radio<bool>(
                        activeColor: Colors.green[600],
                        value: true,
                        groupValue: _isSelected,
                        onChanged: (_) => _handleRadioValueChanged(
                          module.uid,
                          widget.student.uid,
                          context,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.blueGrey,
                  indent: 20.0,
                  endIndent: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Student",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.file_download_rounded),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Attendance')),
                    ],
                    rows: rows,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
