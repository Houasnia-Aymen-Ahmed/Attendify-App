import 'dart:developer';

import 'package:attendify/shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user.dart';
import 'databases.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  UserHandler _userFromFirebaseUser(User? user) => UserHandler(
        userType: "",
        uid: user!.uid,
        email: user.email!,
      );

  User? get currentUsr => _auth.currentUser;

  Stream<UserHandler> get user =>
      _auth.authStateChanges().map(_userFromFirebaseUser);

  // * This function is responsible for signing in a user with their email and password.
  // * It takes in the user's email and password as parameters.
  // * It attempts to sign in the user using the provided email and password.
  // * If successful, it returns the user as a UserHandler object; otherwise, it returns null.
  // * This function is used in the sign in screen.
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

  // * This function is responsible for signing in a user using Google authentication provider.
  // * It signs the user out from Google, then prompts the user to sign in with their Google account.
  // * If the user is not signed in or their email does not end with "@hns-re2sd.dz", it throws an exception with the message "not-hns".
  // * It then uses the Google authentication credentials to sign in the user and returns the user as a UserHandler object.
  // * This function is used in the sign in screen.
  Future signInWithGoogleProvider() async {
    await googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception("no-email");
    } else if (!googleUser.email.endsWith("@hns-re2sd.dz")) {
      throw Exception("not-hns-email");
    }

    if (!await DatabaseService().isUserRegistered(googleUser.email)) {
      throw Exception("not-registered");
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential result = await _auth.signInWithCredential(credential);
    User? user = result.user;
    return _userFromFirebaseUser(user);
  }

  // * This function is responsible for signing up a user using Google authentication provider.
  // * It takes in the user's userType, grade, and speciality as parameters.
  // * If the user is not signed in with an email ending with "@hns-re2sd.dz",
  // * it will throw an exception with the message "not-hns".
  // * It then uses the Google authentication credentials to sign in the user and update the user data in the database.
  // * If the userType is 'teacher', it updates the teacher data; otherwise, it updates the student data and modules with criteria.
  // * Finally, it returns the user from the Firebase user.

  Future signUpWithGoogleProvider(
    String userType,
    String? grade,
    String? speciality,
  ) async {
    await googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception("no-email");
    } else if (!googleUser.email.endsWith("@hns-re2sd.dz")) {
      throw Exception("not-hns-email");
    }

    if (userType.toLowerCase() == 'teacher' &&
        !await DatabaseService().isTeacherEmailRegistered(
          googleUser.email,
        )) {
      throw Exception("not-hns-teacher");
    } else if (userType.toLowerCase() == 'admin' &&
        !await DatabaseService().isAdminEmailRegistered(
          googleUser.email,
        )) {
      throw Exception("not-hns-admin");
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;
    if (userType.toLowerCase() == 'teacher') {
      String userName = capitalizeWords(user!.displayName) ?? "Username";
      await DatabaseService(uid: user.uid).updateUserData(
        userName: userName,
        userType: userType,
        usrUid: user.uid,
        email: user.email!,
        photoURL: user.photoURL!,
      );
      await DatabaseService(uid: user.uid).updateTeacherData(
        userName: userName,
        userType: userType,
        uid: user.uid,
        email: user.email!,
        photoURL: user.photoURL!,
        modules: null,
      );
    } else if (userType.toLowerCase() == 'student') {
      String userName = capitalizeWords(user!.displayName) ?? "Username";
      await DatabaseService(uid: user.uid).updateUserData(
        userName: userName,
        userType: userType,
        usrUid: user.uid,
        email: user.email!,
        photoURL: user.photoURL!,
      );
      await DatabaseService(uid: user.uid).updateStudentData(
        userName: userName,
        userType: userType,
        uid: user.uid,
        email: user.email!,
        photoURL: user.photoURL!,
        grade: grade,
        speciality: speciality,
      );
      await DatabaseService(uid: user.uid).updateModulesWithCriteria(
        grade: grade,
        speciality: speciality,
        studentUID: user.uid,
        studentName: userName,
      );
    } else {
      String userName = capitalizeWords(user!.displayName) ?? "Username";
      await DatabaseService(uid: user.uid).updateUserData(
        userName: userName,
        userType: userType,
        usrUid: user.uid,
        email: user.email!,
        photoURL: user.photoURL!,
      );
    }
    return _userFromFirebaseUser(user);
  }

  // * This function is responsible for signing up a user with email and password
  // * It takes in the user's name, email, password, user type, and optional modules, grade, and speciality
  // * It creates a new user with the provided email and password, then updates the user data in the database
  // * If the user type is 'teacher', it updates the teacher data with the provided modules
  // * If the user type is 'student', it updates the student data with the provided grade and speciality, and also updates modules with criteria
  // * Finally, it returns the user from the Firebase user.
  // * This function is used in the sign up screen.

  Future signUpWithEmailAndPassword(
    String userName,
    String email,
    String password,
    String userType, {
    List<String>? modules,
    String? grade,
    String? speciality,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      await DatabaseService(uid: user?.uid).updateUserData(
        userName: userName,
        userType: userType,
        usrUid: user!.uid,
        email: user.email!,
        photoURL: user.photoURL!,
      );

      if (userType == 'teacher') {
        await DatabaseService(uid: user.uid).updateTeacherData(
          userName: userName,
          userType: userType,
          uid: user.uid,
          email: user.email!,
          photoURL: user.photoURL!,
          modules: modules,
        );
      } else {
        await DatabaseService(uid: user.uid).updateStudentData(
          userName: userName,
          userType: userType,
          uid: user.uid,
          email: user.email!,
          photoURL: user.photoURL!,
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

  // * Logs the user out and displays a snackbar with the result

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
