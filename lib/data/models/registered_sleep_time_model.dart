import 'package:cloud_firestore/cloud_firestore.dart';

/// Período de sueño registrado. Colección: registeredSleepTimes.
class RegisteredSleepTimeModel {
  final String id;
  final String userId;
  final String name;
  final DateTime startTimestamp;
  final DateTime endTimestamp;
  final DateTime createdAt;

  const RegisteredSleepTimeModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.startTimestamp,
    required this.endTimestamp,
    required this.createdAt,
  });

  /// Duración en minutos.
  int get durationMinutes =>
      endTimestamp.difference(startTimestamp).inMinutes;

  /// Duración formateada (ej. "8h 30m").
  String get durationFormatted {
    final d = endTimestamp.difference(startTimestamp);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  String get startTimeFormatted =>
      '${startTimestamp.hour.toString().padLeft(2, '0')}:${startTimestamp.minute.toString().padLeft(2, '0')}';
  String get endTimeFormatted =>
      '${endTimestamp.hour.toString().padLeft(2, '0')}:${endTimestamp.minute.toString().padLeft(2, '0')}';

  Map<String, Object?> toMap() {
    return {
      'userId': userId,
      'name': name,
      'startTimestamp': Timestamp.fromDate(startTimestamp),
      'endTimestamp': Timestamp.fromDate(endTimestamp),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RegisteredSleepTimeModel.fromMap(String id, Map<String, dynamic> map) {
    final toDateTime = (dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    };
    return RegisteredSleepTimeModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      startTimestamp: toDateTime(map['startTimestamp']),
      endTimestamp: toDateTime(map['endTimestamp']),
      createdAt: toDateTime(map['createdAt']),
    );
  }
}
