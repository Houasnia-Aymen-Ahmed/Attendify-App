import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:attendify/models/app_notification.dart';
import 'package:attendify/models/attendance_waiver.dart';
import 'package:attendify/models/code_request.dart';
import 'package:attendify/models/live_session.dart';
import 'package:attendify/models/session_check_in.dart';
import 'package:attendify/models/session_code.dart';
import 'package:attendify/models/user.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/services/notification_service.dart';
import 'package:attendify/services/session_service.dart';
import 'package:attendify/services/waiver_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService(
    authService: ref.watch(authServiceProvider),
  );
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final waiverServiceProvider = Provider<WaiverService>((ref) {
  return WaiverService(
    authService: ref.watch(authServiceProvider),
  );
});

final authStateProvider = StreamProvider<UserHandler?>((ref) {
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

final activeSessionProvider = StreamProvider.family<LiveSession?, String>(
  (ref, String moduleId) {
    return ref.watch(sessionServiceProvider).streamActiveSession(moduleId);
  },
);

final teacherSessionsProvider = StreamProvider.family<List<LiveSession>, String>(
  (ref, String teacherId) {
    return ref.watch(sessionServiceProvider).streamTeacherSessions(teacherId);
  },
);

final studentEligibleSessionsProvider =
    StreamProvider.family<List<LiveSession>, String>(
  (ref, String studentId) {
    return ref
        .watch(sessionServiceProvider)
        .streamStudentEligibleSessions(studentId);
  },
);

final sessionCheckInsProvider =
    StreamProvider.family<List<SessionCheckIn>, String>(
  (ref, String sessionId) {
    return ref.watch(sessionServiceProvider).streamSessionCheckIns(sessionId);
  },
);

final studentSessionCheckInProvider =
    StreamProvider.family<SessionCheckIn?, ({String sessionId, String studentId})>(
  (ref, key) {
    return ref.watch(sessionServiceProvider).streamStudentSessionCheckIn(
          key.sessionId,
          key.studentId,
        );
  },
);

final studentCodeProvider =
    StreamProvider.family<SessionCode?, ({String sessionId, String studentId})>(
  (ref, key) => ref
      .watch(sessionServiceProvider)
      .streamStudentCode(key.sessionId, key.studentId),
);

final codeRequestsProvider =
    StreamProvider.family<List<CodeRequest>, String>(
  (ref, sessionId) =>
      ref.watch(sessionServiceProvider).streamCodeRequests(sessionId),
);

final notificationsProvider =
    StreamProvider.family<List<AppNotification>, String>(
  (ref, String userId) {
    return ref.watch(notificationServiceProvider).streamNotifications(userId);
  },
);

final studentWaiversProvider =
    StreamProvider.family<List<AttendanceWaiver>, String>(
  (ref, String studentId) {
    return ref.watch(waiverServiceProvider).streamStudentWaivers(studentId);
  },
);

final adminWaiversProvider = StreamProvider<List<AttendanceWaiver>>((ref) {
  return ref.watch(waiverServiceProvider).streamAdminWaivers();
});
