import 'package:intl/intl.dart';

import '../models/module_model.dart';

String todayAttendanceKey([DateTime? dateTime]) {
  return DateFormat('dd-MM-yyyy').format(dateTime ?? DateTime.now());
}

DateTime? parseAttendanceDate(String value) {
  try {
    return DateFormat('dd-MM-yyyy').parseStrict(value);
  } catch (_) {
    return null;
  }
}

List<String> sortedAttendanceDates(
  Module module, {
  bool descending = true,
}) {
  final dates = module.attendanceTable.keys.cast<String>().toList();
  dates.sort((left, right) {
    final leftDate = parseAttendanceDate(left);
    final rightDate = parseAttendanceDate(right);
    if (leftDate == null || rightDate == null) {
      return left.compareTo(right);
    }
    return leftDate.compareTo(rightDate);
  });
  return descending ? dates.reversed.toList() : dates;
}

int moduleStudentCount(Module module) {
  return module.students.isNotEmpty ? module.students.length : module.numberOfStudents;
}

int presentCountForDate(Module module, String date) {
  final attendance = module.attendanceTable[date];
  if (attendance is! Map) {
    return 0;
  }
  return attendance.values.where((value) => value == true).length;
}

int absentCountForDate(Module module, String date) {
  final studentCount = moduleStudentCount(module);
  if (studentCount == 0) {
    return 0;
  }
  return studentCount - presentCountForDate(module, date);
}

double moduleAttendancePercentage(Module module) {
  if (module.attendanceTable.isEmpty) {
    return 0;
  }

  final studentCount = moduleStudentCount(module);
  if (studentCount == 0) {
    return 0;
  }

  int totalPresent = 0;
  for (final date in module.attendanceTable.keys) {
    totalPresent += presentCountForDate(module, date);
  }

  final totalPossible = module.attendanceTable.length * studentCount;
  if (totalPossible == 0) {
    return 0;
  }

  return (totalPresent / totalPossible) * 100;
}

int studentPresentSessions(Module module, String studentId) {
  int total = 0;
  for (final attendance in module.attendanceTable.values) {
    if (attendance is Map && attendance[studentId] == true) {
      total += 1;
    }
  }
  return total;
}

double studentAttendancePercentage(Module module, String studentId) {
  if (module.attendanceTable.isEmpty) {
    return 0;
  }
  return (studentPresentSessions(module, studentId) / module.attendanceTable.length) *
      100;
}

bool studentCheckedInForDate(
  Module module,
  String studentId,
  String date,
) {
  final attendance = module.attendanceTable[date];
  return attendance is Map && attendance[studentId] == true;
}
