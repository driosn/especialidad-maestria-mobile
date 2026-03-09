import 'package:equilibra_mobile/data/models/default_ingredient_model.dart';
import 'package:equilibra_mobile/data/models/meal_type_model.dart';
import 'package:equilibra_mobile/data/models/registered_meal_model.dart';

class AlimentacionState {
  AlimentacionState({
    DateTime? selectedDate,
    this.mealTypes = const [],
    this.defaultIngredients = const [],
    this.meals = const [],
    this.pendingMealIds = const {},
    this.loading = false,
    this.error,
  }) : selectedDate = selectedDate ?? DateTime.now();

  final DateTime selectedDate;
  final List<MealTypeModel> mealTypes;
  final List<DefaultIngredientModel> defaultIngredients;
  final List<RegisteredMealModel> meals;
  final Set<String> pendingMealIds;
  final bool loading;
  final String? error;

  num get totalKcal =>
      meals.fold<num>(0, (s, m) => s + m.totalKcal);
  num get totalCarbs =>
      meals.fold<num>(0, (s, m) => s + m.totalCarbs);
  num get totalProteins =>
      meals.fold<num>(0, (s, m) => s + m.totalProteins);

  AlimentacionState copyWith({
    DateTime? selectedDate,
    List<MealTypeModel>? mealTypes,
    List<DefaultIngredientModel>? defaultIngredients,
    List<RegisteredMealModel>? meals,
    Set<String>? pendingMealIds,
    bool? loading,
    String? error,
  }) {
    return AlimentacionState(
      selectedDate: selectedDate ?? this.selectedDate,
      mealTypes: mealTypes ?? this.mealTypes,
      defaultIngredients: defaultIngredients ?? this.defaultIngredients,
      meals: meals ?? this.meals,
      pendingMealIds: pendingMealIds ?? this.pendingMealIds,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}
