import 'package:attendify/models/user_of_attendify.dart';

class Teacher extends AttendifyUser {
  List<String>? modules = [];
  Teacher({
    required String userName,
    required String userType,
    required String token,
    required String uid,
    this.modules,
  }) : super(
          userName: userName,
          userType: userType,
          token: token,
          uid: uid,
        );
}
