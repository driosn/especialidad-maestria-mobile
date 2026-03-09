import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equilibra_mobile/data/models/meal_type_model.dart';
import 'package:equilibra_mobile/data/models/registered_meal_ingredient_model.dart';
import 'package:equilibra_mobile/data/models/registered_meal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String _collection = 'registeredMeals';

class RegisteredMealsService {
  RegisteredMealsService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collection);

  String? get _userId => _auth.currentUser?.uid;
  String? get currentUserId => _userId;

  /// Comidas registradas para un día.
  Future<List<RegisteredMealModel>> getByDate(DateTime date) async {
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

    return snap.docs
        .map((d) => RegisteredMealModel.fromMap(d.id, d.data()))
        .toList();
  }

  Stream<List<RegisteredMealModel>> watchByDate(DateTime date) {
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
        .map((snap) => snap.docs
            .map((d) => RegisteredMealModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<RegisteredMealModel?> get(String id) async {
    final doc = await _col.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return RegisteredMealModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  Future<String> create({
    required MealTypeRef mealType,
    required List<RegisteredMealIngredientModel> ingredients,
    required DateTime date,
  }) async {
    final uid = _userId;
    if (uid == null) throw StateError('User not logged in');

    final ref = _col.doc();
    final now = DateTime.now();
    final meal = RegisteredMealModel(
      id: ref.id,
      userId: uid,
      mealType: mealType,
      ingredients: ingredients,
      createdAt: now,
      date: DateTime(date.year, date.month, date.day),
    );
    await ref.set(meal.toMap());
    return ref.id;
  }

  Future<void> update(
    String id, {
    MealTypeRef? mealType,
    List<RegisteredMealIngredientModel>? ingredients,
  }) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists || doc.data() == null) return;

    final current = RegisteredMealModel.fromMap(doc.id, doc.data()!);
    final newMealType = mealType ?? current.mealType;
    final newIngredients = ingredients ?? current.ingredients;
    await _col.doc(id).update({
      'mealType': newMealType.toMap(),
      'ingredients': newIngredients.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> addIngredient(
    String mealId,
    RegisteredMealIngredientModel ingredient,
  ) async {
    final meal = await get(mealId);
    if (meal == null) return;
    final list = [...meal.ingredients, ingredient];
    await update(mealId, ingredients: list);
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}

