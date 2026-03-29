import 'package:attendify/models/module_model.dart';
import 'package:attendify/utils/module_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Module Metrics Tests', () {
    late Module testModule;

    setUp(() {
      testModule = Module(
        uid: 'mod1',
        name: 'CS101',
        isActive: true,
        speciality: 'CS',
        grade: '1st',
        numberOfStudents: 2,
        students: {'s1': 'Student 1', 's2': 'Student 2'},
        attendanceTable: {
          '01-01-2023': {'s1': true, 's2': false},
          '02-01-2023': {'s1': true, 's2': true},
        },
      );
    });

    test('todayAttendanceKey should return correctly formatted date', () {
      final date = DateTime(2023, 10, 25);
      expect(todayAttendanceKey(date), '25-10-2023');
    });

    test('parseAttendanceDate should parse date string correctly', () {
      final date = parseAttendanceDate('25-10-2023');
      expect(date?.day, 25);
      expect(date?.month, 10);
      expect(date?.year, 2023);
    });

    test('sortedAttendanceDates should return dates in descending order by default', () {
      final dates = sortedAttendanceDates(testModule);
      expect(dates, ['02-01-2023', '01-01-2023']);
    });

    test('moduleStudentCount should return correct count', () {
      expect(moduleStudentCount(testModule), 2);
    });

    test('presentCountForDate should return correct count', () {
      expect(presentCountForDate(testModule, '01-01-2023'), 1);
      expect(presentCountForDate(testModule, '02-01-2023'), 2);
    });

    test('absentCountForDate should return correct count', () {
      expect(absentCountForDate(testModule, '01-01-2023'), 1);
      expect(absentCountForDate(testModule, '02-01-2023'), 0);
    });

    test('moduleAttendancePercentage should return correct percentage', () {
      // Total present: 1 + 2 = 3
      // Total possible: 2 dates * 2 students = 4
      // Percentage: (3/4) * 100 = 75%
      expect(moduleAttendancePercentage(testModule), 75.0);
    });

    test('studentPresentSessions should return correct count', () {
      expect(studentPresentSessions(testModule, 's1'), 2);
      expect(studentPresentSessions(testModule, 's2'), 1);
    });

    test('studentAttendancePercentage should return correct percentage', () {
      expect(studentAttendancePercentage(testModule, 's1'), 100.0);
      expect(studentAttendancePercentage(testModule, 's2'), 50.0);
    });

    test('studentCheckedInForDate should return correct status', () {
      expect(studentCheckedInForDate(testModule, 's1', '01-01-2023'), isTrue);
      expect(studentCheckedInForDate(testModule, 's2', '01-01-2023'), isFalse);
    });
  });
}
