import 'package/flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth.dart';
import '../../services/providers.dart';

enum SignInState { idle, loading, success, error }

class SignInController extends StateNotifier<SignInState> {
  final AuthService _authService;

  SignInController(this._authService) : super(SignInState.idle);

  String? error;

  Future<void> signIn() async {
    state = SignInState.loading;
    error = null;
    try {
      final result = await _authService.signInWithGoogleProvider();
      if (result is Map) {
        error = result['message'] ?? "An unknown error occurred.";
        state = SignInState.error;
      } else {
        state = SignInState.success;
      }
    } catch (e) {
      error = "A client-side error occurred. Please try again.";
      state = SignInState.error;
    }
  }
}

final signInControllerProvider = StateNotifierProvider<SignInController, SignInState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return SignInController(authService);
});
