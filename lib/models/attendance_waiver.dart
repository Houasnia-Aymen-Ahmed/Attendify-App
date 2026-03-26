import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceWaiverStatus {
  pending,
  approved,
  rejected,
}

class AttendanceWaiver {
  final String id;
  final String studentId;
  final String moduleId;
  final String sessionId;
  final String reason;
  final String? attachmentUrl;
  final AttendanceWaiverStatus status;
  final DateTime submittedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewComment;

  const AttendanceWaiver({
    required this.id,
    required this.studentId,
    required this.moduleId,
    required this.sessionId,
    required this.reason,
    this.attachmentUrl,
    required this.status,
    required this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewComment,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'moduleId': moduleId,
      'sessionId': sessionId,
      'reason': reason,
      'attachmentUrl': attachmentUrl,
      'status': status.name,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt == null ? null : Timestamp.fromDate(reviewedAt!),
      'reviewComment': reviewComment,
    };
  }

  factory AttendanceWaiver.fromJson(
    Map<String, dynamic> json, {
    String? id,
  }) {
    return AttendanceWaiver(
      id: id ?? json['id'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      moduleId: json['moduleId'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      attachmentUrl: json['attachmentUrl'] as String?,
      status: attendanceWaiverStatusFromValue(json['status'] as String?),
      submittedAt: _asDateTime(json['submittedAt']) ?? DateTime.now(),
      reviewedBy: json['reviewedBy'] as String?,
      reviewedAt: _asDateTime(json['reviewedAt']),
      reviewComment: json['reviewComment'] as String?,
    );
  }
}

AttendanceWaiverStatus attendanceWaiverStatusFromValue(String? value) {
  return AttendanceWaiverStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => AttendanceWaiverStatus.pending,
  );
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
