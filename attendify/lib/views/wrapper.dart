import 'package:attendify/models/user.dart';
import 'package:attendify/views/home/user_wrapper.dart';
import 'package:attendify/views/type_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserHandler?>(
      builder: (context, user, _) {
        if (user == null) {
          return const TypeWrapper();
        } else {
          return UserWrapper(user: user);
        }
      },
    );
  }
}
