import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:attendify/models/attendance_waiver.dart';
import 'package:attendify/services/auth.dart';

class WaiverService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final AuthService _authService;

  WaiverService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    AuthService? authService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _authService = authService ?? AuthService();

  CollectionReference<Map<String, dynamic>> get _waiverCollection =>
      _firestore.collection('AttendanceWaivers');

  Future<AttendanceWaiver> submitWaiver(
    String sessionId,
    String moduleId,
    String reason,
    File? attachment,
  ) async {
    final studentId = _authService.currentUsr?.uid;
    if (studentId == null) {
      throw StateError('A signed-in student is required to submit a waiver.');
    }

    final doc = _waiverCollection.doc();
    String? attachmentUrl;
    if (attachment != null) {
      final fileName = attachment.path.split('/').last;
      final storageRef = _storage
          .ref()
          .child('attendance_waivers/$studentId/${doc.id}/$fileName');
      await storageRef.putFile(attachment);
      attachmentUrl = await storageRef.getDownloadURL();
    }

    final waiver = AttendanceWaiver(
      id: doc.id,
      studentId: studentId,
      moduleId: moduleId,
      sessionId: sessionId,
      reason: reason,
      attachmentUrl: attachmentUrl,
      status: AttendanceWaiverStatus.pending,
      submittedAt: DateTime.now(),
    );

    await doc.set(waiver.toJson());
    return waiver;
  }

  Stream<List<AttendanceWaiver>> streamStudentWaivers(String studentId) {
    return _waiverCollection
        .where('studentId', isEqualTo: studentId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceWaiver.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Stream<List<AttendanceWaiver>> streamAdminWaivers() {
    return _waiverCollection
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceWaiver.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<void> reviewWaiver(
    String waiverId,
    AttendanceWaiverStatus status,
    String comment,
  ) async {
    final reviewerId = _authService.currentUsr?.uid;
    await _waiverCollection.doc(waiverId).set(
      {
        'status': status.name,
        'reviewComment': comment,
        'reviewedBy': reviewerId,
        'reviewedAt': Timestamp.fromDate(DateTime.now()),
      },
      SetOptions(merge: true),
    );
  }
}
