import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../services/auth.dart';
import '../../services/databases.dart';
import 'type_wrapper.dart';
import 'user_wrapper.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = DatabaseService();
    final AuthService authService = AuthService();
    return Consumer<UserHandler?>(
      builder: (context, user, _) {
        if (user == null) {
          return const TypeWrapper();
        } else {
          return UserWrapper(
            user: user,
            databaseService: databaseService,
            authService: authService,
          );
        }
      },
    );
  }
}
