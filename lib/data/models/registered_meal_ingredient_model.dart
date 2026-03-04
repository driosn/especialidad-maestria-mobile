/// Referencia a un ingrediente dentro de una comida registrada.
/// Usa defaultIngredientId + quantity; los valores nutricionales se calculan desde defaultIngredients.
class RegisteredMealIngredientModel {
  final String defaultIngredientId;
  final num quantity;
  /// Valores caculados/cacheados para esta cantidad (opcional, para no leer defaultIngredient cada vez).
  final num? kcal;
  final num? carbs;
  final num? proteins;
  final String? name;
  final String? unitTypeName;

  const RegisteredMealIngredientModel({
    required this.defaultIngredientId,
    required this.quantity,
    this.kcal,
    this.carbs,
    this.proteins,
    this.name,
    this.unitTypeName,
  });

  Map<String, Object?> toMap() {
    return {
      'defaultIngredientId': defaultIngredientId,
      'quantity': quantity,
      if (kcal != null) 'kcal': kcal,
      if (carbs != null) 'carbs': carbs,
      if (proteins != null) 'proteins': proteins,
      if (name != null) 'name': name,
      if (unitTypeName != null) 'unitTypeName': unitTypeName,
    };
  }

  factory RegisteredMealIngredientModel.fromMap(Map<String, dynamic> map) {
    return RegisteredMealIngredientModel(
      defaultIngredientId: map['defaultIngredientId'] as String? ?? '',
      quantity: (map['quantity'] as num?) ?? 0,
      kcal: map['kcal'] as num?,
      carbs: map['carbs'] as num?,
      proteins: map['proteins'] as num?,
      name: map['name'] as String?,
      unitTypeName: map['unitTypeName'] as String?,
    );
  }
}
