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
      if (result == null) {
        setState(() {
          _isLoading = false;
          _error =
              "Couldn't Register with those Credientials, Please try again";
        });
      }
    } on Exception catch (e) {
      if (e.toString().contains("not-hns-email")) {
        setState(() {
          _isLoading = false;
          _error = "You must use an HNS-RE2SD account";
        });
      } else if (e.toString().contains("no-email")) {
        setState(() {
          _isLoading = false;
          _error = "You must have select an email";
        });
      } else if (e.toString().contains("not-registered")) {
        setState(() {
          _isLoading = false;
          _error = "You are not registered, Please register first";
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = "An error occured while signing in, Please try again";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = "A server error occured while signing in, Please try again";
      });
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
