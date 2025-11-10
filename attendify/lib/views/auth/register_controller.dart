import 'package/flutter_riverpod/flutter_riverpod.dart';

import 'package:attendify/services/providers.dart';

import '../../services/auth.dart';

enum RegisterState { idle, loading, success, error }

class RegisterController extends StateNotifier<RegisterState> {
  final AuthService _authService;

  RegisterController(this._authService) : super(RegisterState.idle);

  String? error;

  Future<void> signUp(String userType, String? grade, String? speciality) async {
    state = RegisterState.loading;
    error = null;
    try {
      final result = await _authService.signUpWithGoogleProvider(userType, grade, speciality);
      if (result is Map) {
        error = result['message'] ?? "An unknown error occurred.";
        state = RegisterState.error;
      } else {
        state = RegisterState.success;
      }
    } catch (e) {
      error = "A client-side error occurred. Please try again.";
      state = RegisterState.error;
    }
  }
}

final registerControllerProvider = StateNotifierProvider<RegisterController, RegisterState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return RegisterController(authService);
});
