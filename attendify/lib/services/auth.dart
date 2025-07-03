import 'dart:developer';

import 'package:attendify/models/user_of_attendify.dart'; // Assuming UserHandler is here
import 'package:attendify/shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';

// Removed BuildContext import as it's no longer needed for SnackBars
// import 'package:flutter/material.dart';

import '../models/user.dart'; // Ensure this is the correct path for UserHandler
import 'databases.dart';

// Define a type for error results for more clarity
typedef AuthError = Map<String, String>;

class AuthService {
  late final fb_auth.FirebaseAuth _auth;
  late final GoogleSignIn _googleSignIn;
  late final DatabaseService _dbService; // To allow injection

  // Default constructor
  AuthService() {
    _auth = fb_auth.FirebaseAuth.instance;
    _googleSignIn = GoogleSignIn();
    _dbService = DatabaseService(); // Default instance
  }

  // Constructor for testing to allow injecting mocks
  AuthService.test(this._auth, this._googleSignIn, this._dbService);

  UserHandler _userFromFirebaseUser(fb_auth.User? user) {
    if (user == null) {
      // This case should ideally not be reached if called after a successful auth event
      // or should be handled by the caller checking for null user from Firebase.
      // However, to prevent `user!.uid` from crashing if user is unexpectedly null:
      throw Exception("Cannot create UserHandler from null Firebase user.");
    }
    return UserHandler(
      userType: "", // userType is typically fetched from Firestore, not FirebaseUser
      uid: user.uid,
      email: user.email ?? "", // Handle null email, though Firebase usually provides it
    );
  }

  // Public method for testing the private _userFromFirebaseUser
  UserHandler testUserFromFirebaseUser(fb_auth.User? user) {
    return _userFromFirebaseUser(user);
  }

  fb_auth.User? get currentUsr => _auth.currentUser;

  Stream<UserHandler> get user =>
      _auth.authStateChanges().map(_userFromFirebaseUser);

  Future<dynamic> signInWithEmailAndPassword(String email, String password) async {
    try {
      fb_auth.UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return _userFromFirebaseUser(result.user);
    } on fb_auth.FirebaseAuthException catch (e) {
      log('FirebaseAuthException in signInWithEmailAndPassword: ${e.code} - ${e.message}');
      return {'error_code': e.code, 'message': e.message ?? 'Sign in failed.'};
    } catch (e) {
      log('Generic Exception in signInWithEmailAndPassword: $e');
      return {'error_code': 'unknown_error', 'message': 'An unknown error occurred.'};
    }
  }

  Future<dynamic> signInWithGoogleProvider() async {
    try {
      await _googleSignIn.signOut(); // Ensure fresh sign-in attempt
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {'error_code': 'no-email', 'message': 'Google sign-in was cancelled or failed.'};
      }
      if (!googleUser.email.endsWith("@hns-re2sd.dz")) {
        return {'error_code': 'not-hns-email', 'message': 'Email must end with @hns-re2sd.dz'};
      }

      // Use the injected _dbService instance
      if (!await _dbService.isUserRegistered(googleUser.email)) {
        return {'error_code': 'not-registered', 'message': 'User is not registered in the system.'};
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final fb_auth.OAuthCredential credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      fb_auth.UserCredential result = await _auth.signInWithCredential(credential);
      return _userFromFirebaseUser(result.user);
    } on fb_auth.FirebaseAuthException catch (e) {
       log('FirebaseAuthException in signInWithGoogleProvider: ${e.code} - ${e.message}');
      return {'error_code': e.code, 'message': e.message ?? 'Google sign in failed.'};
    } catch (e) {
      log('Generic Exception in signInWithGoogleProvider: $e');
      // Check if it's one of our custom error strings from before
      if (e.toString().contains("no-email")) return {'error_code': 'no-email', 'message': 'Google sign-in was cancelled or failed.'};
      if (e.toString().contains("not-hns-email")) return {'error_code': 'not-hns-email', 'message': 'Email must end with @hns-re2sd.dz'};
      if (e.toString().contains("not-registered")) return {'error_code': 'not-registered', 'message': 'User is not registered in the system.'};
      return {'error_code': 'unknown_error', 'message': 'An unknown error occurred during Google sign-in.'};
    }
  }

  Future<dynamic> signUpWithGoogleProvider(
    String userType,
    String? grade,
    String? speciality,
  ) async {
    try {
      await _googleSignIn.signOut(); // Ensure fresh sign-in attempt
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {'error_code': 'no-email', 'message': 'Google sign-up was cancelled or failed.'};
      }
      if (!googleUser.email.endsWith("@hns-re2sd.dz")) {
        return {'error_code': 'not-hns-email', 'message': 'Email must end with @hns-re2sd.dz for sign-up.'};
      }

      // Use the injected _dbService instance
      if (userType.toLowerCase() == 'teacher' &&
          !await _dbService.isTeacherEmailRegistered(googleUser.email)) {
        return {'error_code': 'not-hns-teacher', 'message': 'Teacher email is not authorized.'};
      } else if (userType.toLowerCase() == 'admin' &&
          !await _dbService.isAdminEmailRegistered(googleUser.email)) {
        return {'error_code': 'not-hns-admin', 'message': 'Admin email is not authorized.'};
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final fb_auth.OAuthCredential credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final fb_auth.UserCredential userCredential = await _auth.signInWithCredential(credential);
      final fb_auth.User? user = userCredential.user;

      if (user == null) {
        return {'error_code': 'user-creation-failed', 'message': 'Failed to create user with Google.'};
      }

      String userName = capitalizeWords(user.displayName) ?? "Username";
      String photoURL = user.photoURL ?? "";

      // Use the injected _dbService instance, ensuring it has the uid
      final userDbService = DatabaseService(uid: user.uid);


      await userDbService.updateUserData(
        userName: userName, userType: userType, usrUid: user.uid,
        email: user.email!, photoURL: photoURL,
      );

      if (userType.toLowerCase() == 'teacher') {
        await userDbService.updateTeacherData(
          userName: userName, userType: userType, uid: user.uid,
          email: user.email!, photoURL: photoURL, modules: null,
        );
      } else if (userType.toLowerCase() == 'student') {
        await userDbService.updateStudentData(
          userName: userName, userType: userType, uid: user.uid,
          email: user.email!, photoURL: photoURL, grade: grade, speciality: speciality,
        );
        await userDbService.updateModulesWithCriteria(
          grade: grade, speciality: speciality, studentUID: user.uid, studentName: userName,
        );
      }
      // Admin type only needs generic user data from updateUserData

      return _userFromFirebaseUser(user);
    } on fb_auth.FirebaseAuthException catch (e) {
      log('FirebaseAuthException in signUpWithGoogleProvider: ${e.code} - ${e.message}');
      return {'error_code': e.code, 'message': e.message ?? 'Google sign up failed.'};
    } catch (e) {
      log('Generic Exception in signUpWithGoogleProvider: $e');
      if (e.toString().contains("no-email")) return {'error_code': 'no-email', 'message': 'Google sign-up was cancelled or failed.'};
      if (e.toString().contains("not-hns-email")) return {'error_code': 'not-hns-email', 'message': 'Email must end with @hns-re2sd.dz for sign-up.'};
      if (e.toString().contains("not-hns-teacher")) return {'error_code': 'not-hns-teacher', 'message': 'Teacher email is not authorized.'};
      if (e.toString().contains("not-hns-admin")) return {'error_code': 'not-hns-admin', 'message': 'Admin email is not authorized.'};
      return {'error_code': 'unknown_error', 'message': 'An unknown error occurred during Google sign-up.'};
    }
  }

  Future<dynamic> signUpWithEmailAndPassword(
    String userName,
    String email,
    String password,
    String userType, {
    List<String>? modules,
    String? grade,
    String? speciality,
  }) async {
    try {
      fb_auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final fb_auth.User? user = result.user;

      if (user == null) {
         return {'error_code': 'user-creation-failed', 'message': 'Failed to create user.'};
      }

      String photoURL = user.photoURL ?? "";

      // Use the injected _dbService or a new one with UID
      final userDbService = DatabaseService(uid: user.uid);

      await userDbService.updateUserData(
        userName: userName, userType: userType, usrUid: user.uid,
        email: user.email!, photoURL: photoURL,
      );

      if (userType.toLowerCase() == 'teacher') {
        await userDbService.updateTeacherData(
          userName: userName, userType: userType, uid: user.uid,
          email: user.email!, photoURL: photoURL, modules: modules,
        );
      } else if (userType.toLowerCase() == 'student') {
        await userDbService.updateStudentData(
          userName: userName, userType: userType, uid: user.uid,
          email: user.email!, photoURL: photoURL, grade: grade, speciality: speciality,
        );
        await userDbService.updateModulesWithCriteria(
          grade: grade, speciality: speciality, studentUID: user.uid, studentName: userName,
        );
      }
      // Admin type only needs generic user data from updateUserData

      return _userFromFirebaseUser(user);
    } on fb_auth.FirebaseAuthException catch (e) {
      log('FirebaseAuthException in signUpWithEmailAndPassword: ${e.code} - ${e.message}');
      return {'error_code': e.code, 'message': e.message ?? 'Sign up failed.'};
    } catch (e) {
      log('Generic Exception in signUpWithEmailAndPassword: $e');
      return {'error_code': 'unknown_error', 'message': 'An unknown error occurred during sign-up.'};
    }
  }

  // Logs the user out. Returns true on success, false on failure.
  // Removed BuildContext as it's no longer showing SnackBars.
  Future<bool> logout() async {
    try {
      await _auth.signOut();
      // Optionally, could also sign out from Google if that's desired on every logout
      // await _googleSignIn.signOut();
      log("Logout successful via AuthService");
      return true;
    } catch (e) {
      log("Error during logout in AuthService: $e");
      return false;
    }
  }
}
