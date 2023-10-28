import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/views/home/modules_list.dart';
import 'package:flutter/material.dart';

class BuildBody extends StatefulWidget {
  final Student student;
  const BuildBody({super.key, required this.student});

  @override
  State<BuildBody> createState() => _BuildBodyState();
}

class _BuildBodyState extends State<BuildBody> {
  @override
  Widget build(BuildContext context) {
    return ModuleList(student:widget.student);
  }
}
