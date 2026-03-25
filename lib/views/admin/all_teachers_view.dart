import 'package:attendify/services/providers.dart';
import 'package:attendify/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../components/popups.dart';
import '../../models/attendify_teacher.dart';

class AllTeachersView extends ConsumerStatefulWidget {
  const AllTeachersView({super.key});

  @override
  ConsumerState<AllTeachersView> createState() => _AllTeachersViewState();
}

class _AllTeachersViewState extends ConsumerState<AllTeachersView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teachersAsyncValue = ref.watch(allTeachersAndEmailsProvider);
    return teachersAsyncValue.when(
      data: (teachersAndEmails) {
        final allTeachers = teachersAndEmails['teachers'] as List<Teacher>;
        final allEmails = teachersAndEmails['emails'] as List<String>;
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
                  listViewBuilder(context, allTeachers, "teachers"),
                  listViewBuilder(context, allEmails, "emails"),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(error.toString())),
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
                  () {
                    final databaseService = ref.read(databaseServiceProvider);
                    if (itemsType == "teachers") {
                      databaseService.removeTeacherById(items[index].uid);
                    } else {
                      databaseService.removeTeacherEmail(items[index]);
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
