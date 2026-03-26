import 'package:cloud_firestore/cloud_firestore.dart';

class SessionCode {
  final String id;
  final String sessionId;
  final String studentId;
  final String code;
  final DateTime issuedAt;

  static const int expirySeconds = 60;
  static const int displaySeconds = 6;

  const SessionCode({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.code,
    required this.issuedAt,
  });

  bool get isExpired =>
      DateTime.now().isAfter(issuedAt.add(const Duration(seconds: expirySeconds)));

  int get secondsRemaining {
    final expiry = issuedAt.add(const Duration(seconds: expirySeconds));
    return expiry.difference(DateTime.now()).inSeconds.clamp(0, expirySeconds);
  }

  factory SessionCode.fromJson(Map<String, dynamic> json, {String? id}) {
    return SessionCode(
      id: id ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      code: json['code'] as String? ?? '',
      issuedAt: _asDateTime(json['issuedAt']) ?? DateTime.now(),
    );
  }
}

DateTime? _asDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
