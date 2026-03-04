import 'dart:async';

import 'package:equilibra_mobile/data/models/default_exercise_model.dart';
import 'package:equilibra_mobile/data/models/registered_exercise_model.dart';
import 'package:equilibra_mobile/data/services/default_exercises_service.dart';
import 'package:equilibra_mobile/data/services/registered_exercises_service.dart';
import 'package:equilibra_mobile/presentation/cubits/ejercicio_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EjercicioCubit extends Cubit<EjercicioState> {
  EjercicioCubit({
    DefaultExercisesService? defaultExercisesService,
    RegisteredExercisesService? registeredExercisesService,
  })  : _defaultExercises =
            defaultExercisesService ?? DefaultExercisesService(),
        _registeredExercises =
            registeredExercisesService ?? RegisteredExercisesService(),
        super(EjercicioState()) {
    _loadInitial();
    _subscription = _registeredExercises
        .watchByDate(state.selectedDate)
        .listen(_onExercisesUpdated);
  }

  final DefaultExercisesService _defaultExercises;
  final RegisteredExercisesService _registeredExercises;
  StreamSubscription<List<RegisteredExerciseModel>>? _subscription;

  void _onExercisesUpdated(List<RegisteredExerciseModel> exercises) {
    emit(state.copyWith(exercises: exercises));
  }

  Future<void> _loadInitial() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final exercises = await _defaultExercises.getAll();
      final registered =
          await _registeredExercises.getByDate(state.selectedDate);
      emit(state.copyWith(
        defaultExercises: exercises,
        exercises: registered,
        loading: false,
      ));
      _subscription?.cancel();
      _subscription = _registeredExercises
          .watchByDate(state.selectedDate)
          .listen(_onExercisesUpdated);
    } catch (e, _) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void setDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    emit(state.copyWith(selectedDate: day, exercises: []));
    _subscription?.cancel();
    _subscription =
        _registeredExercises.watchByDate(day).listen(_onExercisesUpdated);
  }

  Future<void> registerExercise({
    required DefaultExerciseModel exercise,
    required DateTime date,
    required num duration,
    required num distance,
    required num kcal,
    required num series,
    required num reps,
    required num weight,
  }) async {
    try {
      await _registeredExercises.create(
        exercise: exercise,
        date: date,
        duration: duration,
        distance: distance,
        kcal: kcal,
        series: series,
        reps: reps,
        weight: weight,
      );
      // Refrescar lista para que calorías y tiempo activo se actualicen de inmediato
      final updated =
          await _registeredExercises.getByDate(state.selectedDate);
      emit(state.copyWith(exercises: updated));
    } catch (e, _) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteExercise(String id) async {
    await _registeredExercises.delete(id);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
