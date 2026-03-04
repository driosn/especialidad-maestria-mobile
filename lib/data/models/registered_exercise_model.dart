import 'package:cloud_firestore/cloud_firestore.dart';

/// Ejercicio registrado. Colección: registeredExercises.
class RegisteredExerciseModel {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime createdAt;
  final String exerciseId;
  final String exerciseName;
  final String exerciseType; // Cardio | Peso
  final num duration;
  final num distance;
  final num kcal;
  final num series;
  final num reps;
  final num weight;

  const RegisteredExerciseModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.createdAt,
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseType,
    required this.duration,
    required this.distance,
    required this.kcal,
    required this.series,
    required this.reps,
    required this.weight,
  });

  bool get isCardio => exerciseType == 'Cardio';
  bool get isPeso => exerciseType == 'Peso';

  Map<String, Object?> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'exerciseType': exerciseType,
      'duration': duration.toDouble(),
      'distance': distance.toDouble(),
      'kcal': kcal.toDouble(),
      'series': series.toDouble(),
      'reps': reps.toDouble(),
      'weight': weight.toDouble(),
    };
  }

  factory RegisteredExerciseModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    final date = map['date'];
    return RegisteredExerciseModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      date: date is Timestamp
          ? date.toDate()
          : (date is DateTime ? date : DateTime.now()),
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : (createdAt is DateTime ? createdAt : DateTime.now()),
      exerciseId: map['exerciseId'] as String? ?? '',
      exerciseName: map['exerciseName'] as String? ?? '',
      exerciseType: map['exerciseType'] as String? ?? 'Peso',
      duration: (map['duration'] as num?) ?? 0,
      distance: (map['distance'] as num?) ?? 0,
      kcal: (map['kcal'] as num?) ?? 0,
      series: (map['series'] as num?) ?? 0,
      reps: (map['reps'] as num?) ?? 0,
      weight: (map['weight'] as num?) ?? 0,
    );
  }
}
