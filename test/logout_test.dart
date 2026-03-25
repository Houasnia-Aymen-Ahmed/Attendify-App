import 'package:attendify/services/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService', () {
    final authService = AuthService();
    const context = null;

    test('should return a user when signing in with email and password', () {
      final user = authService.signInWithEmailAndPassword('email', 'password');
      expect(user, isNotNull);
    });

    test('should return null when signing in with email and password fails', () {
      final user = authService.signInWithEmailAndPassword('email', 'wrongPassword');
      expect(user, isNull);
    });

    test('should return a user when signing in with Google', () {
      final user = authService.signInWithGoogleProvider();
      expect(user, isNotNull);
    });

    test('should return null when signing in with Google fails', () {
      final user = authService.signInWithGoogleProvider();
      expect(user, isNull);
    });

    test('should return a user when signing up with email and password', () {
      final user = authService.signUpWithEmailAndPassword(
          'username', 'email', 'password', 'teacher');
      expect(user, isNotNull);
    });

    test('should return null when signing up with email and password fails', () {
      final user = authService.signUpWithEmailAndPassword(
          'username', 'email', 'password', 'teacher');
      expect(user, isNull);
    });

    test('should return a user when signing up with Google', () {
      final user = authService.signUpWithGoogleProvider('teacher', null, null);
      expect(user, isNotNull);
    });

    test('should return null when signing up with Google fails', () {
      final user = authService.signUpWithGoogleProvider('teacher', null, null);
      expect(user, isNull);
    });

    test('should log out the user', () {
      authService.logout(context);
      expect(authService.currentUsr, isNull);
    });
  });
}
