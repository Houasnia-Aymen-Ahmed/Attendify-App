import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:attendify/services/providers.dart';

enum RegisterState { idle, loading, success, error }

class RegisterController extends Notifier<RegisterState> {
  String? error;

  @override
  RegisterState build() {
    return RegisterState.idle;
  }

  void reset() {
    error = null;
    state = RegisterState.idle;
  }

  Future<void> signUp(
      String userType, String? grade, String? speciality) async {
    state = RegisterState.loading;
    error = null;
    final authService = ref.read(authServiceProvider);
    try {
      final result = await authService.signUpWithGoogleProvider(
          userType, grade, speciality);
      if (result == null) {
        error = "Couldn't Register with those credentials, Please try again";
        state = RegisterState.error;
      } else {
        state = RegisterState.success;
      }
    } on Exception catch (e) {
      final message = e.toString();

      if (message.contains('not-hns-email')) {
        error = 'You must use an HNS-RE2SD account';
      } else if (message.contains('no-email')) {
        error = 'You must have select an email';
      } else if (message.contains('not-hns-teacher')) {
        error =
            "Sorry, you don't have permission to register as a teacher, please contact the administration";
      } else if (message.contains('not-hns-admin')) {
        error =
            "Sorry, you don't have permission to register as an admin, please contact the administration";
      } else {
        error = 'An error occurred while registering, Please try again';
      }

      state = RegisterState.error;
    } catch (e) {
      error = 'A server error occurred while registering, Please try again';
      state = RegisterState.error;
    }
  }
}

final registerControllerProvider =
    NotifierProvider<RegisterController, RegisterState>(RegisterController.new);
