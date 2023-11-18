import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth.dart';
import '../../shared/constants.dart';

class StudentRegister extends StatefulWidget {
  final Function toggleView;
  const StudentRegister({super.key, required this.toggleView});

  @override
  State<StudentRegister> createState() => _StudentRegisterState();
}

class _StudentRegisterState extends State<StudentRegister> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _name = "", _email = "", _password = "", _error = "";
  bool _obsecureText = true;
  bool isDisabled = true;
  bool loading = false;
  List<String> specialitiesKeys = specialities.keys.toList();
  String? gradeValue;
  String? specialityValue;

  void buttonController() async {
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);
      dynamic result = _auth.signUpWithEmailAndPassword(
        _name,
        _email,
        _password,
        "student",
        grade: gradeValue,
        speciality: specialityValue,
      );
      if (result == null) {
        setState(() {
          loading = false;
          _error =
              "Couldn't Register with those Credientials, Please try again";
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
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 350,
                maxHeight: 750,
              ),
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
                  color: Colors.white30,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(flex: 2),
                    Text(
                      "Sign up",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(flex: 2),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 275),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: DropdownButton<String>(
                              padding: const EdgeInsets.all(8.0),
                              elevation: 16,
                              dropdownColor: Colors.blue[100],
                              borderRadius: BorderRadius.circular(20),
                              isExpanded: true,
                              value: gradeValue,
                              hint: Text(
                                "Choose your grade",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.blue[900],
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                backgroundColor: Colors.transparent,
                              ),
                              underline: Container(
                                height: 2,
                                color: Colors.blue[900],
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  isDisabled = false;
                                  gradeValue = newValue;
                                });
                              },
                              items: specialitiesKeys
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    capitalizeFirst(value),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 275),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: DropdownButton<String>(
                              padding: const EdgeInsets.all(8.0),
                              elevation: 16,
                              dropdownColor: Colors.blue[100],
                              borderRadius: BorderRadius.circular(20),
                              isExpanded: true,
                              value: specialityValue,
                              hint: Text(
                                "Choose your speciality",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: isDisabled
                                      ? Colors.blueGrey
                                      : Colors.blue[900],
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                backgroundColor: Colors.transparent,
                              ),
                              underline: Container(
                                height: 2,
                                color: isDisabled
                                    ? Colors.blueGrey
                                    : Colors.blue[900],
                              ),
                              onChanged: isDisabled
                                  ? null
                                  : (String? newValue) {
                                      setState(() {
                                        specialityValue = newValue;
                                      });
                                    },
                              items: specialities[gradeValue ?? "Sem 9"]!
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    capitalizeFirst(value),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 275),
                        child: TextFormField(
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: textInputDecoation.copyWith(
                            hintText: "Full Name",
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          enableSuggestions: false,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Please enter a name";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (val) => setState(
                            () => _name = val,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 275),
                        child: TextFormField(
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: textInputDecoation.copyWith(
                            hintText: "Email",
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          enableSuggestions: false,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Please enter an Email";
                            } else if (!val.contains('@')) {
                              return "Please enter a valid Email";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (val) => setState(
                            () => _email = val,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 275,
                        ),
                        child: TextFormField(
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: textInputDecoation.copyWith(
                            hintText: "Password",
                            suffixIcon: IconButton(
                              icon: _obsecureText
                                  ? const Icon(
                                      Icons.visibility_rounded,
                                    )
                                  : const Icon(
                                      Icons.visibility_off_rounded,
                                    ),
                              onPressed: () => setState(
                                () => _obsecureText = !_obsecureText,
                              ),
                              color: Colors.white,
                            ),
                          ),
                          obscureText: _obsecureText,
                          autocorrect: false,
                          enableSuggestions: false,
                          validator: (val) {
                            return val!.length < 6
                                ? "The password must be at least 6 characters long"
                                : null;
                          },
                          onChanged: (val) => setState(
                            () => _password = val,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    ElevatedButton(
                      style: elevatedBtnStyle,
                      onPressed: () async => buttonController(),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                        child: Text("Sign up", style: txt()),
                      ),
                    ),
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
                    const Spacer(flex: 2),
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
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
