import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../services/auth.dart';
import '../../shared/constants.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  final AuthService authService;
  const SignIn({
    super.key,
    required this.toggleView,
    required this.authService,
  });

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String _error = "";
  bool _isLoading = false;

  void buttonController() async {
    setState(() {
      _error = "";
      _isLoading = true;
    });
    try {
      dynamic result = await widget.authService.signInWithGoogleProvider();
      // Successful sign-in is handled by the auth stream listener in Wrapper/main.dart
      // We only need to handle errors here.
      if (result is Map) { // Check if it's an AuthError map
        String errorCode = result['error_code'] ?? 'unknown_error';
        String errorMessage = result['message'] ?? "An unknown error occurred.";

        if (mounted) {
          setState(() {
            _isLoading = false;
            if (errorCode == "not-hns-email") {
              _error = "You must use an HNS-RE2SD account.";
            } else if (errorCode == "no-email") {
              _error = "You must select an email account to sign in.";
            } else if (errorCode == "not-registered") {
              _error = "This account is not registered. Please sign up first.";
            } else {
              _error = errorMessage; // Display the message from AuthService
            }
          });
        }
      } else if (result == null) {
        // This case might occur if AuthService returns null for some other reason,
        // though the refactor aims to return AuthError maps.
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = "Couldn't sign in with those credentials. Please try again.";
          });
        }
      }
      // If result is UserHandler, it's a success, Stream listener will navigate.
      // If sign-in is successful, _isLoading should also be reset if not navigated away.
      // However, typically navigation happens fast. If remaining on page:
      else if (mounted && result != null) { // result is UserHandler
         setState(() {
          _isLoading = false;
          // _error remains empty as it's a success
        });
      }

    } catch (e) { // Catch-all for truly unexpected errors during the call itself
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "A client-side error occurred. Please try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.blue[700]!,
                      Colors.blue[100]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    width: 2,
                    color: Colors.transparent,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 0.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        "Sign in",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          color: Colors.white,
                        ),
                      ),
                      Transform.scale(
                        scale: 1.25,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 50),
                          child: SignInButton(
                            Buttons.google,
                            padding: const EdgeInsets.all(5.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            text: "Sign in with HNS-RE2SD",
                            onPressed: buttonController,
                          ),
                        ),
                      ),
                      if (_error != "")
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 275),
                          child: Text(
                            _error,
                            style: TextStyle(
                              color: Colors.red[900],
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (_isLoading) const CircularProgressIndicator(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "You don't have an account?",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all(
                                Colors.white.withOpacity(0.1),
                              ),
                            ),
                            onPressed: () => widget.toggleView(),
                            child: Text(
                              "Create one",
                              style: txt().copyWith(
                                fontSize: 14.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
