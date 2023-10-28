import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/shared/loading.dart';
import 'package:attendify/views/home/module_from_student.dart';
import 'package:flutter/material.dart';

class ModuleList extends StatefulWidget {
  final Student student;
  const ModuleList({super.key, required this.student});

  @override
  State<ModuleList> createState() => _ModuleListState();
}

class _ModuleListState extends State<ModuleList> {
  List<String> moduleNames = [];
  List<Module> modulesList = [];
  late final Stream<Module> moduleStream;

  final DatabaseService _dataService = DatabaseService();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Module>>(
      stream: _dataService.getModuleDataStream(
        "uid",
        grade: widget.student.grade!,
        speciality: widget.student.speciality!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (!snapshot.hasData) {
          return Text('No snapshot data available ${snapshot.error} ');
        } else {
          List<Module> modules = snapshot.data!;
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
                child: ListView.builder(
                  itemCount: modules.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Card(
                        color: Colors.blue[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          enabled: modules[index].isActive,
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Icon(Icons.circle_rounded,
                                color: modules[index].isActive
                                    ? Colors.green
                                    : Colors.red),
                          ),
                          trailing: IconButton(
                            onPressed: !modules[index].isActive
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ModuleFromStudent(
                                            module: modules[index],
                                            student: widget.student,
                                          );
                                        },
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.arrow_forward_ios_rounded),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          splashColor: Colors.blue[300],
                          contentPadding: const EdgeInsets.all(5.0),
                          title: Text(modules[index].name),
                          onTap: () {},
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
