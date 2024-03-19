import 'package:attendify/shared/error_pages.dart';
import 'package:flutter/material.dart';

import '../../utils/shared_prefs_helper.dart';
import '../statistics/module_stats.dart';

class SearchPage extends SearchDelegate {
  final String itemType;
  final String searchLabel;
  final List<dynamic> allItems;
  final List<dynamic> lastAccessedItems;

  SearchPage({
    required this.itemType,
    required this.allItems,
    required this.lastAccessedItems,
    this.searchLabel = "Search",
  });

  bool get isPerson => itemType != 'module';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue[200],
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.blue[900],
        selectionColor: Colors.white,
        selectionHandleColor: Colors.blue[900],
      ),
    );
  }

  @override
  String? get searchFieldLabel => searchLabel;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  List<dynamic> getItems(List<dynamic> items) {
    return isPerson
        ? items
            .where(
              (element) => element.userName.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList()
        : items
            .where(
              (element) => element.name.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
  }

  @override
  Widget buildResults(BuildContext context) {
    List<dynamic> items = getItems(allItems);
    return buildListView(
      items: items,
      lastAccessedItems: lastAccessedItems,
      isPerson: isPerson,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<dynamic> items = query.isEmpty && lastAccessedItems.isNotEmpty
        ? lastAccessedItems.reversed.toList()
        : getItems(allItems);

    return buildListView(
      items: items,
      lastAccessedItems: lastAccessedItems,
      isPerson: isPerson,
    );
  }

  Widget buildListView({
    required List<dynamic> items,
    required List<dynamic> lastAccessedItems,
    required bool isPerson,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(
          indent: 10.0,
          endIndent: 10.0,
        ),
        itemBuilder: (context, index) {
          dynamic result = items[index];
          return ListTile(
            title: Text(isPerson ? items[index].userName : items[index].name),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              SharedPrefsHelper.saveLastAccessedItems(
                lastAccessedItems,
                itemType,
                result,
              );
              navigateToStats(context, result);
            },
          );
        },
      ),
    );
  }

  void navigateToStats(BuildContext context, dynamic result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          switch (itemType) {
            case "module":
              return ModuleStats(
                moduleId: result.uid,
                moduleName: result.name,
                students: result.students,
                numberOfStudents: result.numberOfStudents,
              );
            case "teacher":
              return ModuleStats(
                moduleId: result.uid,
                moduleName: result.name,
                students: result.students,
                numberOfStudents: result.numberOfStudents,
              );
            case "student":
              return ModuleStats(
                moduleId: result.uid,
                moduleName: result.name,
                students: result.students,
                numberOfStudents: result.numberOfStudents,
              );
            default:
              return const ErrorPages(
                title: "Server Error",
                message:
                    "Not statistics found as the type is invalid\n(Please select a module, teacher or a student)",
              );
          }
        },
      ),
    );
  }
}
