import 'dart:async';

import 'package:equilibra_mobile/data/models/registered_meal_ingredient_model.dart';
import 'package:equilibra_mobile/data/models/registered_meal_model.dart';
import 'package:equilibra_mobile/data/services/default_ingredients_service.dart';
import 'package:equilibra_mobile/data/services/meal_types_service.dart';
import 'package:equilibra_mobile/data/services/registered_meals_service.dart';
import 'package:equilibra_mobile/presentation/cubits/alimentacion_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlimentacionCubit extends Cubit<AlimentacionState> {
  AlimentacionCubit({
    DefaultIngredientsService? defaultIngredientsService,
    MealTypesService? mealTypesService,
    RegisteredMealsService? registeredMealsService,
  }) : _defaultIngredients =
           defaultIngredientsService ?? DefaultIngredientsService(),
       _mealTypes = mealTypesService ?? MealTypesService(),
       _registeredMeals = registeredMealsService ?? RegisteredMealsService(),
       super(AlimentacionState()) {
    _loadInitial();
    _subscription = _registeredMeals
        .watchByDate(state.selectedDate)
        .listen(_onMealsUpdated);
  }

  final DefaultIngredientsService _defaultIngredients;
  final MealTypesService _mealTypes;
  final RegisteredMealsService _registeredMeals;
  StreamSubscription<List<RegisteredMealModel>>? _subscription;

  void _onMealsUpdated(List<RegisteredMealModel> meals) {
    emit(state.copyWith(meals: meals));
  }

  Future<void> _loadInitial() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final types = await _mealTypes.getAll();
      final ingredients = await _defaultIngredients.getAll();
      final meals = await _registeredMeals.getByDate(state.selectedDate);
      emit(
        state.copyWith(
          mealTypes: types,
          defaultIngredients: ingredients,
          meals: meals,
          loading: false,
        ),
      );
      _subscription?.cancel();
      _subscription = _registeredMeals
          .watchByDate(state.selectedDate)
          .listen(_onMealsUpdated);
    } catch (e, _) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void setDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    emit(state.copyWith(selectedDate: day, meals: []));
    _subscription?.cancel();
    _subscription = _registeredMeals.watchByDate(day).listen(_onMealsUpdated);
  }

  Future<void> addMeal(MealTypeRef mealType) async {
    try {
      await _registeredMeals.create(
        mealType: mealType,
        ingredients: [],
        date: state.selectedDate,
      );
    } catch (e, _) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> addIngredientToMeal(
    String mealId,
    String defaultIngredientId,
    num quantity,
  ) async {
    final def = await _defaultIngredients.get(defaultIngredientId);
    if (def == null) return;
    final factor = quantity / (def.quantity > 0 ? def.quantity : 1);
    final ingredient = RegisteredMealIngredientModel(
      defaultIngredientId: defaultIngredientId,
      quantity: quantity,
      kcal: (def.kcal * factor).roundToDouble(),
      carbs: (def.carbs * factor).roundToDouble(),
      proteins: (def.proteins * factor).roundToDouble(),
      name: def.name,
      unitTypeName: def.unitTypeName,
    );
    await _registeredMeals.addIngredient(mealId, ingredient);
  }

  Future<void> removeIngredient(String mealId, int index) async {
    final meal = state.meals.firstWhere((m) => m.id == mealId);
    final list = [...meal.ingredients]..removeAt(index);
    await _registeredMeals.update(mealId, ingredients: list);
  }

  Future<void> deleteMeal(String mealId) async {
    await _registeredMeals.delete(mealId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
