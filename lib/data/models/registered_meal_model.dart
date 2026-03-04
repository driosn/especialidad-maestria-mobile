import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equilibra_mobile/data/models/registered_meal_ingredient_model.dart';

/// Comida registrada. Colección: registeredMeals.
/// mealType es el tipo (objeto con id/name/iconSrc/color); ingredients lista de referencias a defaultIngredients.
class RegisteredMealModel {
  final String id;
  final String userId;
  final MealTypeRef mealType;
  final List<RegisteredMealIngredientModel> ingredients;
  final DateTime createdAt;
  final DateTime date; // fecha del día al que pertenece la comida

  const RegisteredMealModel({
    required this.id,
    required this.userId,
    required this.mealType,
    required this.ingredients,
    required this.createdAt,
    required this.date,
  });

  num get totalKcal =>
      ingredients.fold<num>(0, (s, i) => s + (i.kcal ?? 0));
  num get totalCarbs =>
      ingredients.fold<num>(0, (s, i) => s + (i.carbs ?? 0));
  num get totalProteins =>
      ingredients.fold<num>(0, (s, i) => s + (i.proteins ?? 0));

  Map<String, Object?> toMap() {
    return {
      'userId': userId,
      'mealType': mealType.toMap(),
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'date': Timestamp.fromDate(date),
    };
  }

  factory RegisteredMealModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    final date = map['date'];
    final mealType = map['mealType'] is Map
        ? MealTypeRef.fromMap(Map<String, dynamic>.from(map['mealType'] as Map))
        : const MealTypeRef(id: '', name: '', iconSrc: '', color: '');
    final ingredientsList = map['ingredients'];
    final ingredients = ingredientsList is List
        ? (ingredientsList)
            .map((e) => RegisteredMealIngredientModel.fromMap(
                Map<String, dynamic>.from(e as Map)))
            .toList()
        : <RegisteredMealIngredientModel>[];

    return RegisteredMealModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      mealType: mealType,
      ingredients: ingredients,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : (createdAt is DateTime ? createdAt : DateTime.now()),
      date: date is Timestamp
          ? date.toDate()
          : (date is DateTime ? date : DateTime.now()),
    );
  }
}

/// Referencia al tipo de comida (guardada en registeredMeal).
class MealTypeRef {
  final String id;
  final String name;
  final String iconSrc;
  final String color;

  const MealTypeRef({
    required this.id,
    required this.name,
    required this.iconSrc,
    required this.color,
  });

  Map<String, Object?> toMap() =>
      {'id': id, 'name': name, 'iconSrc': iconSrc, 'color': color};

  factory MealTypeRef.fromMap(Map<String, dynamic> map) {
    return MealTypeRef(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      iconSrc: map['iconSrc'] as String? ?? '',
      color: map['color'] as String? ?? '#22C55E',
    );
  }
}
