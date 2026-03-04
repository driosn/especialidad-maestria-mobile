import 'package:cloud_firestore/cloud_firestore.dart';

/// Ingrediente por defecto. Colección: defaultIngredients.
class DefaultIngredientModel {
  final String id;
  final String name;
  final String unitType;
  final String unitTypeName;
  final num quantity;
  final num kcal;
  final num carbs;
  final num proteins;
  final DateTime createdAt;

  const DefaultIngredientModel({
    required this.id,
    required this.name,
    required this.unitType,
    required this.unitTypeName,
    required this.quantity,
    required this.kcal,
    required this.carbs,
    required this.proteins,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'unitType': unitType,
      'unitTypeName': unitTypeName,
      'quantity': quantity,
      'kcal': kcal,
      'carbs': carbs,
      'proteins': proteins,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory DefaultIngredientModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    return DefaultIngredientModel(
      id: id,
      name: map['name'] as String? ?? '',
      unitType: map['unitType'] as String? ?? 'g',
      unitTypeName: map['unitTypeName'] as String? ?? 'gramos',
      quantity: (map['quantity'] as num?) ?? 0,
      kcal: (map['kcal'] as num?) ?? 0,
      carbs: (map['carbs'] as num?) ?? 0,
      proteins: (map['proteins'] as num?) ?? 0,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : (createdAt is DateTime ? createdAt : DateTime.now()),
    );
  }

  /// Kcal por unidad (por quantity).
  num get kcalPerUnit => quantity > 0 ? kcal / quantity : 0;
  num get carbsPerUnit => quantity > 0 ? carbs / quantity : 0;
  num get proteinsPerUnit => quantity > 0 ? proteins / quantity : 0;
}
