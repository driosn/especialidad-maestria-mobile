import 'dart:async';
import 'dart:convert';

import 'package:equilibra_mobile/data/models/registered_meal_ingredient_model.dart';
import 'package:equilibra_mobile/data/models/registered_meal_model.dart';
import 'package:equilibra_mobile/data/services/default_ingredients_service.dart';
import 'package:equilibra_mobile/data/services/meal_types_service.dart';
import 'package:equilibra_mobile/data/services/offline_pending_service.dart';
import 'package:equilibra_mobile/data/services/registered_meals_service.dart';
import 'package:equilibra_mobile/presentation/cubits/alimentacion_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlimentacionCubit extends Cubit<AlimentacionState> {
  AlimentacionCubit({
    DefaultIngredientsService? defaultIngredientsService,
    MealTypesService? mealTypesService,
    RegisteredMealsService? registeredMealsService,
    OfflinePendingService? offlinePendingService,
  }) : _defaultIngredients =
           defaultIngredientsService ?? DefaultIngredientsService(),
       _mealTypes = mealTypesService ?? MealTypesService(),
       _registeredMeals = registeredMealsService ?? RegisteredMealsService(),
       _offlinePending = offlinePendingService ?? OfflinePendingService(),
       super(AlimentacionState()) {
    _loadInitial();
    _subscription = _registeredMeals
        .watchByDate(state.selectedDate)
        .listen(_onMealsUpdated);
  }

  final DefaultIngredientsService _defaultIngredients;
  final MealTypesService _mealTypes;
  final RegisteredMealsService _registeredMeals;
  final OfflinePendingService _offlinePending;
  StreamSubscription<List<RegisteredMealModel>>? _subscription;

  Future<void> _mergePending(List<RegisteredMealModel> fromFirestore) async {
    final pending = await _offlinePending.getByCollection(
      'registeredMeals',
      date: state.selectedDate,
    );
    final pendingIds = <String>{};
    final pendingMeals = <RegisteredMealModel>[];
    for (final op in pending) {
      try {
        final map = OfflinePendingService.parseDataMap(op.data);
        pendingMeals.add(RegisteredMealModel.fromMap(op.id, map));
        pendingIds.add(op.id);
      } catch (_) {}
    }
    final existingIds = fromFirestore.map((m) => m.id).toSet();
    final merged = [
      ...fromFirestore,
      ...pendingMeals.where((m) => !existingIds.contains(m.id)),
    ];
    emit(state.copyWith(meals: merged, pendingMealIds: pendingIds));
  }

  void _onMealsUpdated(List<RegisteredMealModel> meals) {
    _mergePending(meals);
  }

  Future<void> _loadInitial() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final types = await _mealTypes.getAll();
      final ingredients = await _defaultIngredients.getAll();
      final meals = await _registeredMeals.getByDate(state.selectedDate);
      await _mergePending(meals);
      emit(
        state.copyWith(
          mealTypes: types,
          defaultIngredients: ingredients,
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
      final uid = _registeredMeals.currentUserId ?? '';
      if (uid.isEmpty) {
        emit(state.copyWith(error: e.toString()));
        return;
      }
      final id = 'off_${DateTime.now().millisecondsSinceEpoch}';
      final meal = RegisteredMealModel(
        id: id,
        userId: uid,
        mealType: mealType,
        ingredients: [],
        createdAt: DateTime.now(),
        date: state.selectedDate,
      );
      final rawMap = Map<String, dynamic>.from(meal.toMap());
      final safeMap = OfflinePendingService.mapToJsonSafe(rawMap);
      await _offlinePending.addPending(
        id: id,
        type: 'POST',
        collection: 'registeredMeals',
        data: jsonEncode(safeMap),
      );
      final merged = [...state.meals, meal];
      final pendingIds = {...state.pendingMealIds, id};
      emit(state.copyWith(meals: merged, pendingMealIds: pendingIds, error: null));
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
    if (state.pendingMealIds.contains(mealId)) {
      await _offlinePending.remove(mealId);
      final nextMeals = state.meals.where((m) => m.id != mealId).toList();
      final nextPending = {...state.pendingMealIds}..remove(mealId);
      emit(state.copyWith(meals: nextMeals, pendingMealIds: nextPending));
      return;
    }
    await _registeredMeals.delete(mealId);
  }

  Future<void> syncPendingMeal(String id) async {
    await _offlinePending.syncOne(id);
    final next = {...state.pendingMealIds}..remove(id);
    emit(state.copyWith(pendingMealIds: next));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
