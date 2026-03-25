import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth.dart';
import '../../services/providers.dart';

enum SignInState { idle, loading, success, error }

class SignInController extends StateNotifier<SignInState> {
  final AuthService _authService;

  SignInController(this._authService) : super(SignInState.idle);

  String? error;

  void reset() {
    error = null;
    state = SignInState.idle;
  }

  Future<void> signIn() async {
    state = SignInState.loading;
    error = null;
    try {
      final result = await _authService.signInWithGoogleProvider();
      if (result == null) {
        error = "Couldn't Register with those credentials, Please try again";
        state = SignInState.error;
      } else {
        state = SignInState.success;
      }
    } on Exception catch (e) {
      final message = e.toString();

      if (message.contains("not-hns-email")) {
        error = "You must use an HNS-RE2SD account";
      } else if (message.contains("no-email")) {
        error = "You must have select an email";
      } else if (message.contains("not-registered")) {
        error = "You are not registered, Please register first";
      } else {
        error = "An error occurred while signing in, Please try again";
      }

      state = SignInState.error;
    } catch (e) {
      error = "A server error occurred while signing in, Please try again";
      state = SignInState.error;
    }
  }
}

final signInControllerProvider = StateNotifierProvider<SignInController, SignInState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return SignInController(authService);
});
