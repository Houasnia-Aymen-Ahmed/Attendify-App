import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth.dart';
import '../../shared/constants.dart';

class TeacherRegister extends StatefulWidget {
  final Function toggleView;
  const TeacherRegister({super.key, required this.toggleView});

  @override
  State<TeacherRegister> createState() => _TeacherRegisterState();
}

class _TeacherRegisterState extends State<TeacherRegister> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _name = "", _email = "", _password = "", _error = "";
  bool _obsecureText = true;
  bool loading = false;

  void buttonController() async {
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);
      dynamic result = _auth.signUpWithEmailAndPassword(
          _name, _email, _password, "teacher",
          modules: []);
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
      decoration: const BoxDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 350,
                maxHeight: 500,
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
