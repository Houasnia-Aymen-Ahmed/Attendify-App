class Module {
  String uid;
  String name;
  bool isActive;
  String speciality;
  String grade;
  Map<String, String> students;
  Map<String, dynamic> attendanceTable;

  Module({
    this.uid = "uid",
    this.name = "name",
    this.isActive = false,
    this.speciality = "speciality",
    this.grade = "grade",
    this.students = const {},
    this.attendanceTable = const {},
  });
}
