import 'package:attendify/services/databases.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../components/popups.dart';
import '../../models/attendify_teacher.dart';

class AllTeachersView extends StatefulWidget {
  final Map<String, dynamic> dataTeachers;
  final DatabaseService databaseService;
  const AllTeachersView(
      {super.key, required this.dataTeachers, required this.databaseService});

  @override
  State<AllTeachersView> createState() => _AllTeachersViewState();
}

class _AllTeachersViewState extends State<AllTeachersView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Teacher> allTeachers = [], teachers = [];
  List<String> allEmails = [];

  @override
  void initState() {
    super.initState();
    allTeachers = widget.dataTeachers['teachers'] as List<Teacher>;
    allEmails = widget.dataTeachers['emails'] as List<String>;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (teachers.isEmpty) {
      teachers = allTeachers;
    }
    return Column(
      children: <Widget>[
        TabBar(
          indicatorPadding: const EdgeInsets.all(5.0),
          padding: const EdgeInsets.all(10.0),
          labelPadding: const EdgeInsets.all(5.0),
          indicatorColor: Colors.blue[900],
          labelColor: Colors.blue[900],
          unselectedLabelColor: Colors.blue[400],
          dividerColor: Colors.blue[100],
          dividerHeight: 2,
          controller: _tabController,
          tabs: const [
            Column(
              children: [
                Icon(FontAwesomeIcons.personChalkboard),
                Text(
                  "Teachers",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Column(
              children: [
                Icon(Icons.email_rounded),
                Text(
                  "Emails",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          flex: 10,
          child: TabBarView(
            controller: _tabController,
            children: [
              listViewBuilder(context, teachers, "teachers"),
              listViewBuilder(context, allEmails, "emails"),
            ],
          ),
        ),
      ],
    );
  }

  Widget listViewBuilder(
    BuildContext context,
    List items,
    String itemsType,
  ) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Card(
            color: Colors.blue[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ListTile(
              trailing: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.delete_outlined,
                  color: Colors.red,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              splashColor: Colors.blue[300],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 5.0,
              ),
              title: Text(
                itemsType == "teachers" ? items[index].userName : items[index],
                style: const TextStyle(fontSize: 18),
              ),
              titleAlignment: ListTileTitleAlignment.threeLine,
              onLongPress: () {
                removeConfirmationDialog(
                  context,
                  itemsType == "teachers" ? "teacher" : "email",
                  itemsType == "teachers"
                      ? () => widget.databaseService
                          .removeTeacherById(items[index].uid)
                      : () => widget.databaseService
                          .removeTeacherEmail(items[index]),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
