import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/code_request.dart';
import '../models/live_session.dart';
import '../models/session_check_in.dart';
import '../models/session_code.dart';
import 'auth.dart';

class SessionService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  SessionService({
    FirebaseFirestore? firestore,
    AuthService? authService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService ?? AuthService();

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _firestore.collection('LiveSessions');

  CollectionReference<Map<String, dynamic>> get _checkIns =>
      _firestore.collection('SessionCheckIns');

  CollectionReference<Map<String, dynamic>> get _codes =>
      _firestore.collection('SessionCodes');

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('CodeRequests');

  String _generateCode() =>
      (100000 + Random.secure().nextInt(900000)).toString();

  // ── Session lifecycle ──────────────────────────────────────────────────────

  Future<LiveSession> startSession(
    String moduleId,
    String roomLabel,
    List<String> eligibleStudentIds,
  ) async {
    final teacherId = _authService.currentUsr?.uid;
    if (teacherId == null) {
      throw StateError('A signed-in teacher is required to start a session.');
    }

    final now = DateTime.now();
    final docRef = _sessions.doc();
    final session = LiveSession(
      id: docRef.id,
      moduleId: moduleId,
      teacherId: teacherId,
      title: roomLabel,
      status: LiveSessionStatus.active,
      startedAt: now,
      roomLabel: roomLabel,
      eligibleStudentIds: eligibleStudentIds,
    );

    await docRef.set(session.toJson());
    return session;
  }

  Future<LiveSession> stopSession(String sessionId) async {
    final sessionDoc = await _sessions.doc(sessionId).get();
    if (!sessionDoc.exists) throw StateError('Session not found.');

    final session = LiveSession.fromJson(sessionDoc.data()!, id: sessionDoc.id);
    final now = DateTime.now();

    await _sessions.doc(sessionId).update({
      'status': LiveSessionStatus.closed.name,
      'endsAt': Timestamp.fromDate(now),
    });

    // Sync successful check-ins to module's legacy attendanceTable
    final snapshot = await _checkIns.where('sessionId', isEqualTo: sessionId).get();

    final presentIds = snapshot.docs
        .map((doc) => SessionCheckIn.fromJson(doc.data(), id: doc.id))
        .where((c) => c.status == SessionCheckInStatus.present)
        .map((c) => c.studentId)
        .toSet();

    final dateKey = DateFormat('dd-MM-yyyy').format(session.startedAt);
    final attendanceEntry = {
      for (final id in session.eligibleStudentIds) id: presentIds.contains(id),
    };

    await _firestore.collection('Modules').doc(session.moduleId).set(
      {'attendanceTable': {dateKey: attendanceEntry}},
      SetOptions(merge: true),
    );

    return session.copyWith(status: LiveSessionStatus.closed, endsAt: now);
  }

  // ── Attendance codes ───────────────────────────────────────────────────────

  /// Generates and silently sends a unique 6-digit code to every eligible student.
  Future<void> sendAttendanceCodes(
    String sessionId,
    List<String> studentIds,
  ) async {
    final batch = _firestore.batch();

    for (final studentId in studentIds) {
      batch.set(_codes.doc('${sessionId}_$studentId'), {
        'sessionId': sessionId,
        'studentId': studentId,
        'code': _generateCode(),
        'issuedAt': FieldValue.serverTimestamp(),
      });
    }

    batch.update(_sessions.doc(sessionId), {
      'codesIssuedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Generates fresh codes for the given students and marks their requests as sent.
  Future<void> resendCodes(
    String sessionId,
    List<String> studentIds,
  ) async {
    final batch = _firestore.batch();

    for (final studentId in studentIds) {
      batch.set(_codes.doc('${sessionId}_$studentId'), {
        'sessionId': sessionId,
        'studentId': studentId,
        'code': _generateCode(),
        'issuedAt': FieldValue.serverTimestamp(),
      });
      batch.update(_requests.doc('${sessionId}_$studentId'), {
        'status': CodeRequestStatus.sent.name,
      });
    }

    batch.update(_sessions.doc(sessionId), {
      'codesIssuedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Student requests a new code after theirs expired.
  Future<void> requestCode(
    String sessionId,
    String studentId,
    String studentName,
  ) async {
    await _requests.doc('${sessionId}_$studentId').set({
      'sessionId': sessionId,
      'studentId': studentId,
      'studentName': studentName,
      'requestedAt': FieldValue.serverTimestamp(),
      'status': CodeRequestStatus.pending.name,
    });
  }

  Stream<SessionCode?> streamStudentCode(String sessionId, String studentId) {
    return _codes.doc('${sessionId}_$studentId').snapshots().map(
          (doc) =>
              doc.exists ? SessionCode.fromJson(doc.data()!, id: doc.id) : null,
        );
  }

  Stream<List<CodeRequest>> streamCodeRequests(String sessionId) {
    return _requests
        .where('sessionId', isEqualTo: sessionId)
        .where('status', isEqualTo: CodeRequestStatus.pending.name)
        .orderBy('requestedAt', descending: false)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => CodeRequest.fromJson(d.data(), id: d.id)).toList());
  }

  // ── Check-in ───────────────────────────────────────────────────────────────

  /// Submits a check-in. The Firestore rule verifies [code] against the
  /// student's SessionCode document and enforces the 60-second window.
  Future<SessionCheckIn> submitCheckIn(String sessionId, String code) async {
    final studentId = _authService.currentUsr?.uid;
    if (studentId == null) {
      throw StateError('A signed-in student is required to submit a check-in.');
    }

    final now = DateTime.now();
    // Deterministic ID: one check-in per student per session
    final docRef = _checkIns.doc('${studentId}_$sessionId');

    await docRef.set({
      'id': docRef.id,
      'sessionId': sessionId,
      'studentId': studentId,
      'checkedInAt': Timestamp.fromDate(now),
      'status': SessionCheckInStatus.present.name,
      'code': code, // validated by Firestore rule
    });

    return SessionCheckIn(
      id: docRef.id,
      sessionId: sessionId,
      studentId: studentId,
      checkedInAt: now,
      status: SessionCheckInStatus.present,
    );
  }

  // ── Streams ────────────────────────────────────────────────────────────────

  Stream<LiveSession?> streamActiveSession(String moduleId) {
    return _sessions
        .where('moduleId', isEqualTo: moduleId)
        .where('status', isEqualTo: LiveSessionStatus.active.name)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty
            ? null
            : LiveSession.fromJson(s.docs.first.data(), id: s.docs.first.id));
  }

  Stream<List<LiveSession>> streamTeacherSessions(String teacherId) {
    return _sessions
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => LiveSession.fromJson(d.data(), id: d.id)).toList());
  }

  Stream<List<LiveSession>> streamStudentEligibleSessions(String studentId) {
    return _sessions
        .where('eligibleStudentIds', arrayContains: studentId)
        .where('status', isEqualTo: LiveSessionStatus.active.name)
        .snapshots()
        .map((s) => s.docs
            .map((d) => LiveSession.fromJson(d.data(), id: d.id))
            .toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt)));
  }

  Stream<List<SessionCheckIn>> streamSessionCheckIns(String sessionId) {
    return _checkIns
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('checkedInAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => SessionCheckIn.fromJson(d.data(), id: d.id)).toList());
  }

  Stream<SessionCheckIn?> streamStudentSessionCheckIn(
    String sessionId,
    String studentId,
  ) {
    return _checkIns
        .where('sessionId', isEqualTo: sessionId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty
            ? null
            : SessionCheckIn.fromJson(s.docs.first.data(), id: s.docs.first.id));
  }
}
