import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo de ejercicio: Cardio o Peso.
const String exerciseTypeCardio = 'Cardio';
const String exerciseTypePeso = 'Peso';

/// Plantilla de ejercicio. Colección: defaultExercises.
class DefaultExerciseModel {
  final String id;
  final String type; // Cardio | Peso
  final String name;
  final num duration; // minutos (referencia en plantilla)
  final num distance; // metros (referencia en plantilla)
  final num kcal; // referencia en plantilla (total ejemplo)
  /// Calorías por minuto: valor fijo por ejercicio. Calorías = duración × kcalPerMinute.
  final num kcalPerMinute;
  final num series;
  final num reps;
  final num weight; // kg
  final DateTime createdAt;

  const DefaultExerciseModel({
    required this.id,
    required this.type,
    required this.name,
    required this.duration,
    required this.distance,
    required this.kcal,
    required this.kcalPerMinute,
    required this.series,
    required this.reps,
    required this.weight,
    required this.createdAt,
  });

  bool get isCardio => type == exerciseTypeCardio;
  bool get isPeso => type == exerciseTypePeso;

  /// Calcula calorías quemadas: duración (min) × kcal por minuto.
  num kcalForDuration(num durationMinutes) =>
      (durationMinutes > 0 && kcalPerMinute > 0)
          ? durationMinutes * kcalPerMinute
          : 0;

  Map<String, Object?> toMap() {
    return {
      'type': type,
      'name': name,
      'duration': duration.toDouble(),
      'distance': distance.toDouble(),
      'kcal': kcal.toDouble(),
      'kcalPerMinute': kcalPerMinute.toDouble(),
      'series': series.toDouble(),
      'reps': reps.toDouble(),
      'weight': weight.toDouble(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory DefaultExerciseModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    final duration = (map['duration'] as num?) ?? 0;
    final kcal = (map['kcal'] as num?) ?? 0;
    final explicitKcalPerMin = map['kcalPerMinute'] as num?;
    final kcalPerMinute = explicitKcalPerMin ??
        (duration > 0 && kcal > 0 ? kcal / duration : 5);
    return DefaultExerciseModel(
      id: id,
      type: map['type'] as String? ?? exerciseTypePeso,
      name: map['name'] as String? ?? '',
      duration: duration,
      distance: (map['distance'] as num?) ?? 0,
      kcal: kcal,
      kcalPerMinute: kcalPerMinute,
      series: (map['series'] as num?) ?? 0,
      reps: (map['reps'] as num?) ?? 0,
      weight: (map['weight'] as num?) ?? 0,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : (createdAt is DateTime ? createdAt : DateTime.now()),
    );
  }
}
