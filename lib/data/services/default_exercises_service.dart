import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equilibra_mobile/data/models/default_exercise_model.dart';

const String _collection = 'defaultExercises';

class DefaultExercisesService {
  DefaultExercisesService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collection);

  Future<List<DefaultExerciseModel>> getAll() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs
        .map((d) => DefaultExerciseModel.fromMap(d.id, d.data()))
        .toList();
  }

  Future<DefaultExerciseModel?> get(String id) async {
    final doc = await _col.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return DefaultExerciseModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  /// Seed: ejercicios Cardio y Peso para elegir.
  Future<void> seed() async {
    final existing = await _col.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now();
    final batch = _firestore.batch();

    // Cardio: name, duration (min), distance (m), kcal (total ejemplo) → kcalPerMinute = kcal/duration
    final cardio = [
      ('Caminata rápida', 30, 5200, 180),   // 6 kcal/min
      ('Trotar', 20, 3000, 200),            // 10
      ('Bicicleta', 45, 15000, 350),        // ~7.8
      ('Natación', 30, 0, 250),             // ~8.3
      ('Elíptica', 25, 4000, 220),          // 8.8
      ('Saltar cuerda', 15, 0, 180),        // 12
      ('Correr', 30, 5000, 320),            // ~10.7
    ];
    for (final (name, duration, distance, kcal) in cardio) {
      final kcalPerMin = duration > 0 ? kcal / duration : 8.0;
      final ref = _col.doc();
      batch.set(ref, {
        'type': exerciseTypeCardio,
        'name': name,
        'duration': duration.toDouble(),
        'distance': distance.toDouble(),
        'kcal': kcal.toDouble(),
        'kcalPerMinute': kcalPerMin.toDouble(),
        'series': 0.0,
        'reps': 0.0,
        'weight': 0.0,
        'createdAt': Timestamp.fromDate(now),
      });
    }

    // Peso: 5 kcal/min por defecto (valor fijo por minuto de ejercicio)
    const pesoKcalPerMin = 5.0;
    final peso = [
      ('Press de banca', 3, 12, 80),
      ('Sentadillas', 4, 10, 100),
      ('Peso muerto', 3, 8, 120),
      ('Press militar', 3, 10, 40),
      ('Remo con barra', 3, 12, 60),
      ('Curl bíceps', 3, 12, 15),
      ('Extensión tríceps', 3, 12, 20),
      ('Dominadas', 3, 8, 0),
      ('Fondos', 3, 10, 0),
      ('Zancadas', 3, 12, 20),
    ];
    for (final (name, series, reps, weight) in peso) {
      final ref = _col.doc();
      batch.set(ref, {
        'type': exerciseTypePeso,
        'name': name,
        'duration': 0.0,
        'distance': 0.0,
        'kcal': 0.0,
        'kcalPerMinute': pesoKcalPerMin,
        'series': series.toDouble(),
        'reps': reps.toDouble(),
        'weight': weight.toDouble(),
        'createdAt': Timestamp.fromDate(now),
      });
    }

    await batch.commit();
  }
}
