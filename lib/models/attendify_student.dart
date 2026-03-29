import 'package:attendify/models/user_of_attendify.dart';

class Student extends AttendifyUser {
  String? grade, speciality;
  Student({
    required super.userName,
    required super.userType,
    required super.uid,
    required super.email,
    required super.photoURL,
    this.grade,
    this.speciality,
  });
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'userName': userName,
      'userType': userType,
      'photoURL': photoURL,
      'grade': grade,
      'speciality': speciality,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      uid: json['uid'] as String,
      email: json['email'] as String,
      userName: json['userName'] as String,
      userType: json['userType'] as String,
      photoURL: json['photoURL'] as String,
      grade: json['grade'] as String?,
      speciality: json['speciality'] as String?,
    );
  }
}
