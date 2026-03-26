import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionCheckInStatus {
  present,
  late,
  rejected,
}

class SessionCheckIn {
  final String id;
  final String sessionId;
  final String studentId;
  final DateTime checkedInAt;
  final SessionCheckInStatus status;

  const SessionCheckIn({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.checkedInAt,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'studentId': studentId,
      'checkedInAt': Timestamp.fromDate(checkedInAt),
      'status': status.name,
    };
  }

  factory SessionCheckIn.fromJson(
    Map<String, dynamic> json, {
    String? id,
  }) {
    return SessionCheckIn(
      id: id ?? json['id'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      checkedInAt: _asDateTime(json['checkedInAt']) ?? DateTime.now(),
      status: sessionCheckInStatusFromValue(json['status'] as String?),
    );
  }
}

SessionCheckInStatus sessionCheckInStatusFromValue(String? value) {
  return SessionCheckInStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => SessionCheckInStatus.rejected,
  );
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
