import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth.dart';
import 'databases.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authServiceProvider).user;
});

final allModulesProvider = FutureProvider((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getAllModules();
});

final allStudentsProvider = FutureProvider((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getAllStudents();
});

final allTeachersAndEmailsProvider = FutureProvider((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getAllTeachersAndEmails();
});

final teacherProvider = StreamProvider.family((ref, String teacherId) {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getTeacherDataStream(teacherId);
});

final teacherModulesProvider = StreamProvider.family((ref, List<String> moduleUIDs) {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getModulesOfTeacher(moduleUIDs);
});

final studentProvider = StreamProvider.family((ref, String studentId) {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getStudentDataStream(studentId);
});

final moduleProvider = StreamProvider.family((ref, String moduleId) {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getModuleStream(moduleId);
});

final studentsProvider = StreamProvider.family((ref, List<String> studentUIDs) {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getStudentsList(studentUIDs);
});

final moduleStatsProvider = FutureProvider.family((ref, String moduleId) {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.fetchModuleStats(moduleId);
});
