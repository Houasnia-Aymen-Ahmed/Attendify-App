import 'package:flutter/material.dart';

import 'signin.dart';
import 'register.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({
    super.key,
  });

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  void toggleView() => setState(() => showSignIn = !showSignIn);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          AppBar(
            title: const Text(
              "Attendify",
              style: TextStyle(
                fontSize: 50,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.blue[200],
            elevation: 20,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            toolbarHeight: 150,
          ),
          Expanded(
            child: showSignIn
                ? Register(
                    toggleView: toggleView,
                  )
                : SignIn(
                    toggleView: toggleView,
                  ),
          )
        ],
      ),
    );
  }
}
