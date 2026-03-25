import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../components/custom_dropdown_btn.dart';
import '../../shared/constants.dart';
import 'register_controller.dart';

class Register extends ConsumerStatefulWidget {
  final VoidCallback toggleView;
  const Register({
    super.key,
    required this.toggleView,
  });

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register> {
  String _validationError = "";
  bool _isDisabled = true, _isGradeDisabled = true;
  String? _typeVal, _gradeVal, _specialityVal;

  Future<void> buttonController() async {
    final registerController = ref.read(registerControllerProvider.notifier);

    if (_typeVal == null) {
      setState(() {
        _validationError = "Please make sure to select a type";
      });
    } else if (_typeVal == "student" &&
        (_gradeVal == null || _specialityVal == null)) {
      setState(() {
        _validationError = "Please make sure to select a 'Grade' & a 'Speciality'";
      });
    } else {
      setState(() {
        _validationError = "";
      });
      await registerController.signUp(_typeVal!, _gradeVal, _specialityVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerControllerProvider);
    final registerController = ref.read(registerControllerProvider.notifier);
    final errorText = _validationError.isNotEmpty
        ? _validationError
        : registerState == RegisterState.error
            ? registerController.error ?? ""
            : "";

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
                                  registerController.reset();
                                  setState(() {
                                    if (newValue != "student") {
                                      _isGradeDisabled = true;
                                      _isDisabled = true;
                                    } else {
                                      _isGradeDisabled = false;
                                    }
                                    _validationError = "";
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
                                        registerController.reset();
                                        setState(() {
                                          _isDisabled = false;
                                          _validationError = "";
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
                                        registerController.reset();
                                        setState(() {
                                          _validationError = "";
                                          _specialityVal = newValue;
                                        });
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
                      if (errorText.isNotEmpty)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 275),
                          child: Text(
                            errorText,
                            style: TextStyle(
                              color: Colors.red[900],
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (registerState == RegisterState.loading)
                        const CircularProgressIndicator(),
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
                            onPressed: () {
                              registerController.reset();
                              widget.toggleView();
                            },
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
