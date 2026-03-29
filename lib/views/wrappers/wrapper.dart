import 'package:attendify/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:attendify/shared/error_pages.dart';
import 'package:attendify/shared/loading.dart';
import 'package:attendify/views/auth/authenticate.dart';
import 'package:attendify/views/wrappers/user_wrapper.dart';

class Wrapper extends ConsumerStatefulWidget {
  const Wrapper({super.key});

  @override
  ConsumerState<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends ConsumerState<Wrapper> {
  String? _registeredTokenUserId;

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final databaseService = ref.watch(databaseServiceProvider);

    return ref.watch(authStateProvider).when(
      data: (user) {
        if (user == null) {
          _registeredTokenUserId = null;
          return const Authenticate();
        }

        // Register FCM token once per user session
        if (_registeredTokenUserId != user.uid) {
          _registeredTokenUserId = user.uid;
          Future.microtask(
            () => ref
                .read(notificationServiceProvider)
                .registerDeviceToken(user.uid!),
          );
        }

        return UserWrapper(
          user: user,
          databaseService: databaseService,
          authService: authService,
        );
      },
      loading: () => const Loading(),
      error: (error, _) => ErrorPages(
        title: 'Auth Error',
        message: error.toString(),
      ),
    );
  }
}
