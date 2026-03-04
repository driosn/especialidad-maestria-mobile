import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equilibra_mobile/data/models/meal_type_model.dart';

const String _collection = 'mealTypes';

class MealTypesService {
  MealTypesService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collection);

  Future<List<MealTypeModel>> getAll() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs
        .map((d) => MealTypeModel.fromMap(d.id, d.data()))
        .toList();
  }

  Future<MealTypeModel?> get(String id) async {
    final doc = await _col.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return MealTypeModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  /// Seed: Desayuno, Merienda, Almuerzo, Cena, Otro.
  Future<void> seed() async {
    final snap = await _col.limit(1).get();
    if (snap.docs.isNotEmpty) return; // ya existe

    final now = DateTime.now();
    final types = [
      ('Desayuno', 'sunny', '#EAB308'),
      ('Merienda', 'coffee', '#F97316'),
      ('Almuerzo', 'restaurant', '#3B82F6'),
      ('Cena', 'nightlight_round', '#8B5CF6'),
      ('Otro', 'more_horiz', '#6B7280'),
    ];

    final batch = _firestore.batch();
    for (final (name, iconSrc, color) in types) {
      final ref = _col.doc();
      batch.set(ref, {
        'name': name,
        'iconSrc': iconSrc,
        'color': color,
        'createdAt': Timestamp.fromDate(now),
      });
    }
    await batch.commit();
  }
}
