import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/attendify_teacher.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/shared/error_pages.dart';
import 'package:flutter/material.dart';

import 'package:attendify/theme/attendify_theme.dart';

import 'package:attendify/utils/shared_prefs_helper.dart';
import 'package:attendify/views/statistics/module_stats.dart';

class SearchPage extends SearchDelegate<dynamic> {
  final String itemType;
  final String searchLabel;
  final List<dynamic> allItems;
  final List<dynamic> lastAccessedItems;

  SearchPage({
    required this.itemType,
    required this.allItems,
    required this.lastAccessedItems,
    this.searchLabel = 'Search',
  });

  bool get isPerson => itemType != 'module';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: AttendifyPalette.primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AttendifyPalette.tertiary,
        selectionColor: Colors.white,
        selectionHandleColor: AttendifyPalette.tertiary,
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
          query = '';
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
              (element) => (element.userName as String).toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList()
        : items
            .where(
              (element) => (element.name as String).toLowerCase().contains(
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
            title: Text(isPerson ? (result.userName as String) : (result.name as String)),
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
      MaterialPageRoute<void>(
        builder: (context) {
          switch (itemType) {
            case 'module':
              final module = result as Module;
              return ModuleStats(
                moduleId: module.uid,
                moduleName: module.name,
                students: module.students,
                numberOfStudents: module.numberOfStudents,
              );
            case 'teacher':
              final teacher = result as Teacher;
              return ModuleStats(
                moduleId: teacher.uid,
                moduleName: teacher.userName,
                students: const {}, // Teacher might not have students directly like this
                numberOfStudents: 0,
              );
            case 'student':
              final student = result as Student;
              return ModuleStats(
                moduleId: student.uid,
                moduleName: student.userName,
                students: const {},
                numberOfStudents: 0,
              );
            default:
              return const ErrorPages(
                title: 'Server Error',
                message:
                    'Not statistics found as the type is invalid\n(Please select a module, teacher or a student)',
              );
          }
        },
      ),
    );
  }
}
