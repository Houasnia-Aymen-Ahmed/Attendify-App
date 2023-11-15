import 'package:attendify/shared/error_pages.dart';
import 'package:flutter/material.dart';

import '../../models/attendify_student.dart';
import '../../models/module_model.dart';
import '../../services/auth.dart';
import '../../services/databases.dart';
import '../../shared/loading.dart';
import '../../shared/module_list_view.dart';

class BuildBody extends StatefulWidget {
  final Student student;
  final DatabaseService databaseService;
  final AuthService authService;
  const BuildBody({
    super.key,
    required this.student,
    required this.databaseService,
    required this.authService,
  });

  @override
  State<BuildBody> createState() => _BuildBodyState();
}

class _BuildBodyState extends State<BuildBody> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Module>>(
      stream: widget.databaseService.getModuleByGradeSpeciality(
        widget.student.grade!,
        widget.student.speciality!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (snapshot.hasError) {
          return ErrorPages(
            title: "Server Error",
            message: snapshot.error.toString(),
          );
        } else if (!snapshot.hasData) {
          return const ErrorPages(
              title: "Error 404: Not Found",
              message: "No module data available for student");
        } else {
          List<Module> modules = snapshot.data!;
          print(modules[0].name);
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(25.0),
                child: Text(
                  'Modules',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ModuleListView(
                  modules: modules,
                  userType: "student",
                  student: widget.student,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
