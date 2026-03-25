import 'package:attendify/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/error_pages.dart';
import '../../shared/loading.dart';
import '../auth/authenticate.dart';
import 'user_wrapper.dart';

class Wrapper extends ConsumerWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final databaseService = ref.watch(databaseServiceProvider);

    return ref.watch(authStateProvider).when(
      data: (user) {
        if (user == null) {
          return const Authenticate();
        }

        return UserWrapper(
          user: user,
          databaseService: databaseService,
          authService: authService,
        );
      },
      loading: () => const Loading(),
      error: (error, stackTrace) => ErrorPages(
        title: "Auth Error",
        message: error.toString(),
      ),
    );
  }
}
