import 'user_of_attendify.dart';

class Teacher extends AttendifyUser {
  List<String>? modules = [];
  Teacher({
    required super.uid,
    required super.email,
    required super.userName,
    required super.userType,
    required super.photoURL,
    this.modules,
  });
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'userName': userName,
      'userType': userType,
      'photoURL': photoURL,
      'modules': modules,
    };
  }

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      uid: json['uid'],
      email: json['email'],
      userName: json['userName'],
      userType: json['userType'],
      photoURL: json['photoURL'],
      modules: json['modules'].cast<String>(),
    );
  }
}
