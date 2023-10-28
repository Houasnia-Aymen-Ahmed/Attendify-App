import 'package:attendify/models/user_of_attendify.dart';

class Student extends AttendifyUser {
  String? grade, speciality;
  Student({
    required String userName,
    required String userType,
    required String token,
    required String uid,
    this.grade,
    this.speciality,
  }) : super(
          userName: userName,
          userType: userType,
          token: token,
          uid: uid,
        );
}
