import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/theme/attendify_ui.dart';
import 'package:attendify/views/auth/signin_controller.dart';

class SignIn extends ConsumerWidget {
  final VoidCallback toggleView;

  const SignIn({
    super.key,
    required this.toggleView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signInState = ref.watch<SignInState>(signInControllerProvider);
    final signInController = ref.read<SignInController>(signInControllerProvider.notifier);
    final errorText =
        signInState == SignInState.error ? signInController.error ?? '' : '';

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: AttendifySurface(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AttendifySectionHeader(
                eyebrow: 'Welcome back',
                title: 'Access your dashboard',
                subtitle:
                    'Continue with your HNS Google account to reach your student, teacher, or admin space.',
              ),
              const SizedBox(height: 20),
              const Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _AuthFactChip(label: 'HNS-only access'),
                  _AuthFactChip(label: 'Google sign-in'),
                  _AuthFactChip(label: 'Role-aware dashboard'),
                ],
              ),
              const SizedBox(height: 24),
              AttendifyPrimaryButton(
                label: 'Continue with Google',
                icon: Icons.arrow_forward_rounded,
                isLoading: signInState == SignInState.loading,
                onPressed: signInController.signIn,
              ),
              if (errorText.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AttendifyPalette.error.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    errorText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AttendifyPalette.error,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AttendifyPalette.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How access works',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Use your `@hns-re2sd.dz` account. If you are already registered, Attendify routes you directly to the correct role area.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Need first-time access?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      signInController.reset();
                      toggleView();
                    },
                    child: const Text('Create your account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthFactChip extends StatelessWidget {
  final String label;

  const _AuthFactChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AttendifyPalette.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AttendifyPalette.primary,
            ),
      ),
    );
  }
}
