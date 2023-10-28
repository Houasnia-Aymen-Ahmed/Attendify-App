import 'package:attendify/shared/constants.dart';
import 'package:attendify/views/auth/authenticate.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TypeWrapper extends StatefulWidget {
  const TypeWrapper({super.key});

  @override
  State<TypeWrapper> createState() => _TypeWrapperState();
}

class _TypeWrapperState extends State<TypeWrapper> {
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        elevation: 10,
        backgroundColor: Colors.blue[200],
        title: const Text("Attendify"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
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
                  items: <String>['teacher', 'student']
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
                  child: dropdownValue == "teacher"
                      ? const Expanded(
                          flex: 1,
                          child: Authenticate(userType: "teacher"),
                        )
                      : const Expanded(
                          flex: 1,
                          child: Authenticate(userType: "student"),
                        ),
                )
              : const SizedBox(height: 25),
          const SizedBox(height: 25),
          /* Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: FloatingActionButton.extended(
              label: const Text(
                "Next",
                style: TextStyle(fontSize: 20),
              ),
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              backgroundColor: Colors.blue[900],
              foregroundColor: Colors.white,
              onPressed: (() {
                if (dropdownValue != null) {
                  dropdownValue == "student"
                      ? Navigator.pushNamed(context, '/studentRegister')
                      : Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TeacherRegister(),
                          ),
                        );
                }
              }),
            ),
          ) */
        ],
      ),
    );
  }
}
