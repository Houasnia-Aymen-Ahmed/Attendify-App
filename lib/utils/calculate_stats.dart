import '../shared/school_data.dart';

class CalculateStats {
  static Map<String, num> _calculateTotal(
    attendanceTable,
    totalStudents,
    totalPresent,
  ) {
    attendanceTable.forEach((date, attendanceMap) {
      totalStudents += attendanceMap.length;
      totalPresent += attendanceMap.values
          .where(
            (value) => value == true,
          )
          .length;
    });
    return {
      'totalStudents': totalStudents,
      'totalPresent': totalPresent,
    };
  }

  static double _calculateRate(num totalPresent, num totalStudents) =>
      (totalPresent / totalStudents) * 100;

  static double calculateOverallAttendanceRate() {
    num totalStudents = 0;
    num totalPresent = 0;

    for (var module in randomModuleData) {
      final total = _calculateTotal(
        module.attendanceTable,
        totalStudents,
        totalPresent,
      );
      totalStudents = total['totalStudents']!;
      totalPresent = total['totalPresent']!;
    }

    return _calculateRate(totalPresent, totalStudents);
  }

  static Map<String, double> calculateAttendanceRate() {
    Map<String, double> moduleWiseAttendanceRates = {};

    for (var module in randomModuleData) {
      num totalStudents = 0;
      num totalPresent = 0;

      final total = _calculateTotal(
        module.attendanceTable,
        totalStudents,
        totalPresent,
      );
      totalStudents = total['totalStudents']!;
      totalPresent = total['totalPresent']!;

      moduleWiseAttendanceRates[module.name] = _calculateRate(
        totalPresent,
        totalStudents,
      );
    }
    return moduleWiseAttendanceRates;
  }

  static Map<double, List<String>> identifyhHighestAndLowestModule() {
    Map<String, double> moduleWiseAttendanceRates = calculateAttendanceRate();
    double highestRate = getHighest(true, moduleWiseAttendanceRates);
    double lowestRate = getHighest(false, moduleWiseAttendanceRates);

    return {
      highestRate: getListOfModulesNames(
        highestRate,
        moduleWiseAttendanceRates,
      ),
      lowestRate: getListOfModulesNames(
        lowestRate,
        moduleWiseAttendanceRates,
      ),
    };
  }

  static Map<String, double> getHighests(
    Map<String, double> moduleWiseAttendanceRates,
    bool mode,
  ) {
    double attendanceRate = moduleWiseAttendanceRates.values.reduce(
      (value, element) => mode
          ? value > element
              ? value
              : element
          : value < element
              ? value
              : element,
    );

    return moduleWiseAttendanceRates.entries
        .where((entry) => entry.value == attendanceRate)
        .toList()
        .asMap()
        .map(
          (index, entry) => MapEntry(entry.key, entry.value),
        );
  }

  static double getHighest(
    bool mode,
    Map<String, double> moduleWiseAttendanceRates,
  ) {
    return moduleWiseAttendanceRates.values.reduce(
      (value, element) => mode
          ? value > element
              ? value
              : element
          : value < element
              ? value
              : element,
    );
  }

  static List<String> getListOfModulesNames(
    double attendanceRate,
    Map<String, double> moduleWiseAttendanceRates,
  ) {
    return moduleWiseAttendanceRates.entries
        .where((entry) => entry.value == attendanceRate)
        .map((entry) => entry.key)
        .toList();
  }
}
