import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/attendify_student.dart';
import '../../../models/module_model.dart';
import '../../../services/databases.dart';

class PresenceTable extends StatefulWidget {
  final List<Student> students;
  final Module module;
  final DatabaseService databaseService;

  const PresenceTable({
    super.key,
    required this.students,
    required this.module,
    required this.databaseService,
  });

  @override
  State<PresenceTable> createState() => _PresenceTableState();
}

class _PresenceTableState extends State<PresenceTable> {
  List<String> dates = [];
  List<String> studentList = [];

  @override
  void initState() {
    super.initState();
    dates = widget.module.attendanceTable.keys.toList();
    studentList = widget.students.map((student) => student.uid).toList();
  }

  void enablePresence(String todayDate) async {
    Map<String, dynamic> newAttendance = {todayDate: {}};

    for (String uid in studentList) {
      newAttendance[todayDate][uid] = false;
    }
    widget.databaseService.addToAttendanceTable(
      widget.module.uid,
      newAttendance,
    );
  }

  Future<void> _exportData(columns, rows) async {
    Excel excelData = Excel.createExcel();
    Sheet sheetObject = excelData['Sheet1'];

    for (var i = 0; i < columns.length; i++) {
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = columns[i].label;
    }

    for (var i = 0; i < rows.length; i++) {
      for (var j = 0; j < rows[i].cells.length; j++) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
            .value = (rows[i].cells[j].child as Text).data! as CellValue?;
      }
    }

    String? result = await FilePicker.platform.getDirectoryPath();
    String name = '$result/${widget.module.name.replaceAll(' ', '_')}.xlsx';

    try {
      File returnedFile = File(name);
      await returnedFile.writeAsBytes(excelData.encode()!);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Success',
              style: TextStyle(
                color: Colors.green,
                fontSize: 22.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'The attendece table has been exported successfully.',
              style: TextStyle(fontSize: 20.0),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Error',
              style: TextStyle(
                color: Colors.red,
                fontSize: 22.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'An error occurred while exporting attendence table.',
              style: TextStyle(fontSize: 20.0),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dates = widget.module.attendanceTable.keys.toList();
    List<DataColumn> columns = <DataColumn>[
      const DataColumn(label: Text('Student ID')),
      const DataColumn(label: Text('Student Name')),
      ...dates.map((date) => DataColumn(label: Text(date))),
    ];
    List<DataRow> rows = List.generate(
      studentList.length,
      (index) {
        String studentId = studentList[index];
        return DataRow(
          cells: <DataCell>[
            DataCell(
              Text(
                studentId.substring(0, 4),
              ),
            ),
            DataCell(Text(widget.students[index].userName)),
            ...dates.map(
              (date) {
                return DataCell(
                  Text(
                    widget.module.attendanceTable[date][studentId] ?? false
                        ? "Present"
                        : "Absent",
                  ),
                );
              },
            ),
          ],
        );
      },
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  "Enable module presence",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              Switch(
                value: widget.module.isActive,
                onChanged: (val) {
                  widget.module.isActive = val;
                  widget.databaseService.updateModuleSpecificData(
                    uid: widget.module.uid,
                    isActive: val,
                  );

                  if (val) {
                    enablePresence(
                      DateFormat('dd-MM-yyyy').format(
                        DateTime.now(),
                      ),
                    );
                  }
                },
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
                  "Students' Attendance",
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              IconButton(
                onPressed: () => _exportData(columns, rows),
                icon: const Icon(Icons.file_download_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: columns,
                rows: rows,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
