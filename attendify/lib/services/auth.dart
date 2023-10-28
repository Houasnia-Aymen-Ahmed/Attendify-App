import 'package:attendify/models/user.dart';
import 'package:attendify/services/databases.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserHandler _userFromFirebaseUser(User? user) => UserHandler(
        userType: "",
        uid: user!.uid,
      );

  User? get currentUsr => _auth.currentUser;

  Stream<UserHandler> get user =>
      _auth.authStateChanges().map(_userFromFirebaseUser);

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user!);
    } catch (e) {
      return null;
    }
  }

  Future signUpWithEmailAndPassword(
      String userName, String email, String password, String userType,
      {List<String>? modules, String? grade, String? speciality}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      await DatabaseService(uid: user?.uid).updateUserData(
          userName: userName, userType: userType, usrUid: user!.uid);

      if (userType == 'teacher') {
        await DatabaseService(uid: user.uid).updateTeacherData(
          userName: userName,
          userType: userType,
          uid: user.uid,
          modules: modules,
        );
      } else {
        await DatabaseService(uid: user.uid).updateStudentData(
          userName: userName,
          userType: userType,
          uid: user.uid,
          grade: grade,
          speciality: speciality,
        );
        await DatabaseService(uid: user.uid).updateModulesWithCriteria(
          grade: grade,
          speciality: speciality,
          studentUID: user.uid,
          studentName: userName,
        );
      }

      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout(BuildContext context) async {
    void showSnackBar(String text, Color color) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20.0),
          backgroundColor: color,
          dismissDirection: DismissDirection.startToEnd,
          elevation: 20.0,
          content: Text(text),
          action: SnackBarAction(
            textColor: Colors.blue[100],
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }

    try {
      await _auth.signOut();
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(e.toString(), Colors.red[900]!);
    }
    if (!context.mounted) return;
    showSnackBar("Logged out successfully", Colors.blue[900]!);
  }
}
