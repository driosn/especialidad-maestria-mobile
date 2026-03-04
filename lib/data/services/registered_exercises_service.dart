import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equilibra_mobile/data/models/default_exercise_model.dart';
import 'package:equilibra_mobile/data/models/registered_exercise_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String _collection = 'registeredExercises';

class RegisteredExercisesService {
  RegisteredExercisesService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collection);

  String? get _userId => _auth.currentUser?.uid;

  Future<List<RegisteredExerciseModel>> getByDate(DateTime date) async {
    final uid = _userId;
    if (uid == null) return [];

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snap = await _col
        .where('userId', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date')
        .get();

    final list = snap.docs
        .map((d) => RegisteredExerciseModel.fromMap(d.id, d.data()))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Stream<List<RegisteredExerciseModel>> watchByDate(DateTime date) {
    final uid = _userId;
    if (uid == null) return Stream.value([]);

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _col
        .where('userId', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => RegisteredExerciseModel.fromMap(d.id, d.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<String> create({
    required DefaultExerciseModel exercise,
    required DateTime date,
    required num duration,
    required num distance,
    required num kcal,
    required num series,
    required num reps,
    required num weight,
  }) async {
    final uid = _userId;
    if (uid == null) throw StateError('User not logged in');

    final ref = _col.doc();
    final now = DateTime.now();
    final day = DateTime(date.year, date.month, date.day);

    final model = RegisteredExerciseModel(
      id: ref.id,
      userId: uid,
      date: day,
      createdAt: now,
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      exerciseType: exercise.type,
      duration: duration,
      distance: distance,
      kcal: kcal,
      series: series,
      reps: reps,
      weight: weight,
    );
    await ref.set(model.toMap());
    return ref.id;
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
