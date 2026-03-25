import 'package:flutter/material.dart';

class Module extends ChangeNotifier {
  String uid;
  String name;
  bool isActive;
  String speciality;
  String grade;
  int numberOfStudents;
  Map<String, String> students;
  Map<String, dynamic> attendanceTable;

  bool get isActiveNotifier => isActive;

  set isActiveNotifier(bool value) {
    isActive = value;
    notifyListeners();
  }

  Module({
    this.uid = "uid",
    this.name = "name",
    this.isActive = false,
    this.speciality = "speciality",
    this.grade = "grade",
    this.numberOfStudents = 0,
    this.students = const {},
    this.attendanceTable = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'isActive': isActive,
      'speciality': speciality,
      'grade': grade,
      'numberOfStudents': numberOfStudents,
      'students': students,
      'attendanceTable': attendanceTable,
    };
  }

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      uid: json['uid'],
      name: json['name'],
      isActive: json['isActive'],
      speciality: json['speciality'],
      grade: json['grade'],
      numberOfStudents: json['numberOfStudents'],
      students: json['students'].cast<String, String>(),
      attendanceTable: json['attendanceTable'],
    );
  }
}
