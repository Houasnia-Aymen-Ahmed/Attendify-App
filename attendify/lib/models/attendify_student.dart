import 'user_of_attendify.dart';

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
      uid: json['uid'],
      email: json['email'],
      userName: json['userName'],
      userType: json['userType'],
      photoURL: json['photoURL'],
      grade: json['grade'],
      speciality: json['speciality'],
    );
  }
}
