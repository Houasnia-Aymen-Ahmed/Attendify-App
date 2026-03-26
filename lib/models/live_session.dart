import 'package:cloud_firestore/cloud_firestore.dart';

enum LiveSessionStatus {
  scheduled,
  active,
  closed,
}

class LiveSession {
  final String id;
  final String moduleId;
  final String teacherId;
  final String title;
  final LiveSessionStatus status;
  final DateTime startedAt;
  final DateTime? endsAt;
  final DateTime? checkInClosesAt;
  final DateTime? codesIssuedAt;
  final String roomLabel;
  final List<String> eligibleStudentIds;

  const LiveSession({
    required this.id,
    required this.moduleId,
    required this.teacherId,
    required this.title,
    required this.status,
    required this.startedAt,
    this.endsAt,
    this.checkInClosesAt,
    this.codesIssuedAt,
    required this.roomLabel,
    this.eligibleStudentIds = const [],
  });

  LiveSession copyWith({
    String? id,
    String? moduleId,
    String? teacherId,
    String? title,
    LiveSessionStatus? status,
    DateTime? startedAt,
    DateTime? endsAt,
    bool clearEndsAt = false,
    DateTime? checkInClosesAt,
    bool clearCheckInClosesAt = false,
    DateTime? codesIssuedAt,
    bool clearCodesIssuedAt = false,
    String? roomLabel,
    List<String>? eligibleStudentIds,
  }) {
    return LiveSession(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      teacherId: teacherId ?? this.teacherId,
      title: title ?? this.title,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endsAt: clearEndsAt ? null : endsAt ?? this.endsAt,
      checkInClosesAt: clearCheckInClosesAt
          ? null
          : checkInClosesAt ?? this.checkInClosesAt,
      codesIssuedAt: clearCodesIssuedAt ? null : codesIssuedAt ?? this.codesIssuedAt,
      roomLabel: roomLabel ?? this.roomLabel,
      eligibleStudentIds: eligibleStudentIds ?? this.eligibleStudentIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'teacherId': teacherId,
      'title': title,
      'status': status.name,
      'startedAt': Timestamp.fromDate(startedAt),
      'endsAt': endsAt == null ? null : Timestamp.fromDate(endsAt!),
      'checkInClosesAt': checkInClosesAt == null
          ? null
          : Timestamp.fromDate(checkInClosesAt!),
      'codesIssuedAt': codesIssuedAt == null ? null : Timestamp.fromDate(codesIssuedAt!),
      'roomLabel': roomLabel,
      'eligibleStudentIds': eligibleStudentIds,
    };
  }

  factory LiveSession.fromJson(
    Map<String, dynamic> json, {
    String? id,
  }) {
    return LiveSession(
      id: id ?? json['id'] as String? ?? '',
      moduleId: json['moduleId'] as String? ?? '',
      teacherId: json['teacherId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: liveSessionStatusFromValue(json['status'] as String?),
      startedAt: _asDateTime(json['startedAt']) ?? DateTime.now(),
      endsAt: _asDateTime(json['endsAt']),
      checkInClosesAt: _asDateTime(json['checkInClosesAt']),
      codesIssuedAt: _asDateTime(json['codesIssuedAt']),
      roomLabel: json['roomLabel'] as String? ?? '',
      eligibleStudentIds:
          List<String>.from(json['eligibleStudentIds'] as List? ?? const []),
    );
  }
}

LiveSessionStatus liveSessionStatusFromValue(String? value) {
  return LiveSessionStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => LiveSessionStatus.scheduled,
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
