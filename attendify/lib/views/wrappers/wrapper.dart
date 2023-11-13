import 'package:attendify/models/user.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/views/wrappers/user_wrapper.dart';
import 'package:attendify/views/wrappers/type_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
