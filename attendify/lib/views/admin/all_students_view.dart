import 'package:flutter/material.dart';

import '../../models/attendify_student.dart';

class AllStudentsView extends StatefulWidget {
  final List<Student> dataStudents;
  const AllStudentsView({super.key, required this.dataStudents});

  @override
  State<AllStudentsView> createState() => _AllStudentsViewState();
}

class _AllStudentsViewState extends State<AllStudentsView> {
  List<Student> allStudents = [], students = [], searchHistory = [];

  @override
  void initState() {
    super.initState();
    allStudents = widget.dataStudents;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'All Students',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: students.isEmpty ? allStudents.length : students.length,
            itemBuilder: (context, index) {
              final student =
                  students.isEmpty ? allStudents[index] : students[index];
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Card(
                  color: Colors.blue[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    splashColor: Colors.blue[300],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                      vertical: 5.0,
                    ),
                    title: Text(
                      student.userName,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
