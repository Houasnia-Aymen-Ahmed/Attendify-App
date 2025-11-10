import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../components/custom_dropdown_btn.dart';
import '../../services/auth.dart';
import '../../shared/constants.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  final AuthService authService;
  const Register({
    super.key,
    required this.toggleView,
    required this.authService,
  });

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String _error = "";
  bool _isDisabled = true, _isGradeDisabled = true, _isLoading = false;
  String? _typeVal, _gradeVal, _specialityVal;

  void buttonController() async {
    if (_typeVal == null) {
      setState(() {
        _error = "Please make sure to select a type";
      });
    } else if (_typeVal == "student" &&
        (_gradeVal == null || _specialityVal == null)) {
      setState(() {
        _error = "Please make sure to select a 'Grade' & a 'Speciality'";
      });
    } else {
      setState(() {
        _error = "";
        _isLoading = true;
      });
      try {
        dynamic result = await widget.authService.signUpWithGoogleProvider(
          _typeVal!,
          _gradeVal,
          _specialityVal,
        );

        // Successful sign-up is handled by the auth stream listener in Wrapper/main.dart
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
                _error = "You must select an email account to sign up.";
              } else if (errorCode == "not-hns-teacher") {
                _error = "Sorry, you don't have permission to register as a teacher. Please contact the administration.";
              } else if (errorCode == "not-hns-admin") {
                _error = "Sorry, you don't have permission to register as an admin. Please contact the administration.";
              } else {
                _error = errorMessage; // Display the message from AuthService
              }
            });
          }
        } else if (result == null) {
           // This case might occur if AuthService returns null for some other reason
          if (mounted) {
            setState(() {
              _isLoading = false;
              _error = "Couldn't register with those credentials. Please try again.";
            });
          }
        }
        // If result is UserHandler, it's a success, Stream listener will navigate.
        // If sign-up is successful, _isLoading should also be reset.
        else if (mounted && result != null) { // result is UserHandler
           setState(() {
            _isLoading = false;
            // _error remains empty
          });
        }

      } catch (e) { // Catch-all for truly unexpected errors
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = "A client-side error occurred during registration. Please try again.";
          });
        }
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
                        "Sign up",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                              ),
                              child: CustomDrowdownBtn(
                                hint: "Choose type",
                                type: "type",
                                isExpanded: true,
                                typeVal: _typeVal,
                                textColor: Colors.white,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    if (newValue != "student") {
                                      _isGradeDisabled = true;
                                      _isDisabled = true;
                                    } else {
                                      _isGradeDisabled = false;
                                    }
                                    _typeVal = newValue;
                                    _gradeVal = null;
                                    _specialityVal = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9.0,
                                vertical: 8.0,
                              ),
                              child: CustomDrowdownBtn(
                                hint: "Choose grade",
                                type: "grade",
                                isDisabled: _isGradeDisabled,
                                gradeVal: _gradeVal,
                                isExpanded: true,
                                textColor: Colors.white,
                                onChanged: _isGradeDisabled
                                    ? null
                                    : (String? newValue) {
                                        setState(() {
                                          _isDisabled = false;
                                          _gradeVal = newValue;
                                          _specialityVal = null;
                                        });
                                      },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9.0,
                                vertical: 8.0,
                              ),
                              child: CustomDrowdownBtn(
                                hint: "Choose speciality",
                                type: "speciality",
                                isDisabled: _isDisabled,
                                gradeVal: _gradeVal,
                                specialityVal: _specialityVal,
                                isExpanded: true,
                                textColor: Colors.white,
                                onChanged: _isDisabled
                                    ? null
                                    : (String? newValue) {
                                        setState(
                                            () => _specialityVal = newValue);
                                      },
                              ),
                            ),
                          ),
                        ],
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
                            text: "Sign up with HNS-RE2SD",
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
                            "Already have an account?",
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
                              "Sign In",
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
