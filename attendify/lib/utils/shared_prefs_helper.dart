import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendify_student.dart';
import '../models/attendify_teacher.dart';
import '../models/module_model.dart';
import 'functions.dart';

class SharedPrefsHelper {
  static Future<void> saveLastAccessedItems(
    List<dynamic> items,
    String itemType,
    dynamic newItem,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? existingIndex = items.indexWhere((item) => item.uid == newItem.uid);

    if (existingIndex != -1) {
      items.removeAt(existingIndex);
    } else if (items.length > 4) {
      items.removeAt(0);
    }
    items.add(newItem);

    List<String> updatedItemsJson = items.map((item) {
      return json.encode(item.toJson());
    }).toList();
    await prefs.setStringList(
      'lastAccessed${capitalizeFirst(itemType)}s',
      updatedItemsJson,
    );
  }

  static Future<List<dynamic>> getLastAccessedItems(String itemType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? itemsJson =
        prefs.getStringList('lastAccessed${capitalizeFirst(itemType)}s');
    if (itemsJson == null) return [];

    return itemsJson.map((itemJson) {
      Map<String, dynamic> itemMap = json.decode(itemJson);
      switch (itemType) {
        case 'module':
          return Module.fromJson(itemMap);
        case 'teacher':
          return Teacher.fromJson(itemMap);
        case 'student':
          return Student.fromJson(itemMap);
        default:
          throw Exception('Unknown item type');
      }
    }).toList();
  }
}
