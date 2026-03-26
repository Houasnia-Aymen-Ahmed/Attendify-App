import 'package:cloud_firestore/cloud_firestore.dart';

enum CodeRequestStatus { pending, sent, rejected }

class CodeRequest {
  final String id;
  final String sessionId;
  final String studentId;
  final String studentName;
  final DateTime requestedAt;
  final CodeRequestStatus status;

  const CodeRequest({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.requestedAt,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'studentId': studentId,
        'studentName': studentName,
        'requestedAt': Timestamp.fromDate(requestedAt),
        'status': status.name,
      };

  factory CodeRequest.fromJson(Map<String, dynamic> json, {String? id}) {
    return CodeRequest(
      id: id ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      requestedAt: _asDateTime(json['requestedAt']) ?? DateTime.now(),
      status: CodeRequestStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String?),
        orElse: () => CodeRequestStatus.pending,
      ),
    );
  }
}

DateTime? _asDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
