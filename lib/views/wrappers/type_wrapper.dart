/* import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../services/auth.dart';
import '../../shared/constants.dart';
import '../auth/authenticate.dart';

class TypeWrapper extends StatefulWidget {
  final AuthService authService;
  const TypeWrapper({super.key, required this.authService});

  @override
  State<TypeWrapper> createState() => _TypeWrapperState();
}

class _TypeWrapperState extends State<TypeWrapper> {
  String? dropdownValue;


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
            flex: dropdownValue != null ? 0 : 1,
            child: Center(
              child: Container(
                color: Colors.transparent,
                child: DropdownButton<String>(
                  padding: const EdgeInsets.all(8.0),
                  elevation: 16,
                  dropdownColor: Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                  value: dropdownValue,
                  hint: Text(
                    "Choose your user type",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[900]),
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
                      dropdownValue = newValue;
                    });
                  },
                  items: <String>['teacher', 'student', 'HNS User']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        capitalizeFirst(value),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          dropdownValue != null
              ? Container(
                  child: dropdownValue == "HNS User"
                      ? Expanded(
                          child: Center(
                            child: Transform.scale(
                              scale: 1.35,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxHeight: 50),
                                child: SignInButton(
                                  Buttons.google,
                                  padding: const EdgeInsets.all(8.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  text: "Sign in with HNS-RE2SD",
                                  onPressed: () {
                                    print("clicked");
                                    _signIn();
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : dropdownValue == "teacher"
                          ? Expanded(
                              flex: 1,
                              child: Authenticate(
                                //userType: "teacher",
                                authService: widget.authService,
                              ),
                            )
                          : Expanded(
                              flex: 1,
                              child: Authenticate(
                                //userType: "student",
                                authService: widget.authService,
                              ),
                            ),
                )
              : const SizedBox(height: 25)
        ],
      ),
    );
  }
}
 */