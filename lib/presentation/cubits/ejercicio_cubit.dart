import 'dart:async';
import 'dart:convert';

import 'package:equilibra_mobile/data/models/default_exercise_model.dart';
import 'package:equilibra_mobile/data/models/registered_exercise_model.dart';
import 'package:equilibra_mobile/data/services/default_exercises_service.dart';
import 'package:equilibra_mobile/data/services/offline_pending_service.dart';
import 'package:equilibra_mobile/data/services/network_service.dart';
import 'package:equilibra_mobile/data/services/registered_exercises_service.dart';
import 'package:equilibra_mobile/presentation/cubits/ejercicio_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EjercicioCubit extends Cubit<EjercicioState> {
  EjercicioCubit({
    DefaultExercisesService? defaultExercisesService,
    RegisteredExercisesService? registeredExercisesService,
    OfflinePendingService? offlinePendingService,
    NetworkService? networkService,
  })  : _defaultExercises =
            defaultExercisesService ?? DefaultExercisesService(),
        _registeredExercises =
            registeredExercisesService ?? RegisteredExercisesService(),
        _offlinePending = offlinePendingService ?? OfflinePendingService(),
        _network = networkService ?? NetworkService(),
        super(EjercicioState()) {
    _loadInitial();
    _subscription = _registeredExercises
        .watchByDate(state.selectedDate)
        .listen(_onExercisesUpdated);
  }

  final DefaultExercisesService _defaultExercises;
  final RegisteredExercisesService _registeredExercises;
  final OfflinePendingService _offlinePending;
  final NetworkService _network;
  StreamSubscription<List<RegisteredExerciseModel>>? _subscription;

  Future<void> _mergePending(List<RegisteredExerciseModel> fromFirestore) async {
    final pending = await _offlinePending.getByCollection(
      'registeredExercises',
      date: state.selectedDate,
    );
    final pendingIds = <String>{};
    final pendingList = <RegisteredExerciseModel>[];
    for (final op in pending) {
      try {
        final map = OfflinePendingService.parseDataMap(op.data);
        pendingList.add(RegisteredExerciseModel.fromMap(op.id, map));
        pendingIds.add(op.id);
      } catch (_) {}
    }
    final existingIds = fromFirestore.map((e) => e.id).toSet();
    final merged = [
      ...fromFirestore,
      ...pendingList.where((e) => !existingIds.contains(e.id)),
    ];
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    emit(state.copyWith(exercises: merged, pendingExerciseIds: pendingIds));
  }

  void _onExercisesUpdated(List<RegisteredExerciseModel> exercises) {
    _mergePending(exercises);
  }

  Future<void> _loadInitial() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final exercises = await _defaultExercises.getAll();
      final registered =
          await _registeredExercises.getByDate(state.selectedDate);
      await _mergePending(registered);
      emit(state.copyWith(
        defaultExercises: exercises,
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

  /// Recarga ejercicios del día (pull-to-refresh).
  Future<void> refresh() async => _loadInitial();

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
    final hasNet = await _network.hasConnection();

    if (!hasNet) {
      await _saveExerciseOffline(
        exercise: exercise,
        date: date,
        duration: duration,
        distance: distance,
        kcal: kcal,
        series: series,
        reps: reps,
        weight: weight,
      );
      return;
    }

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
      final updated =
          await _registeredExercises.getByDate(state.selectedDate);
      emit(state.copyWith(exercises: updated));
    } catch (e, _) {
      await _saveExerciseOffline(
        exercise: exercise,
        date: date,
        duration: duration,
        distance: distance,
        kcal: kcal,
        series: series,
        reps: reps,
        weight: weight,
        error: e.toString(),
      );
    }
  }

  Future<void> _saveExerciseOffline({
    required DefaultExerciseModel exercise,
    required DateTime date,
    required num duration,
    required num distance,
    required num kcal,
    required num series,
    required num reps,
    required num weight,
    String? error,
  }) async {
    final uid = _registeredExercises.currentUserId ?? '';
    if (uid.isEmpty) {
      emit(state.copyWith(error: error ?? 'Usuario no autenticado'));
      return;
    }
    final id = 'off_${DateTime.now().millisecondsSinceEpoch}';
    final day = DateTime(date.year, date.month, date.day);
    final model = RegisteredExerciseModel(
      id: id,
      userId: uid,
      date: day,
      createdAt: DateTime.now(),
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
    final rawMap = Map<String, dynamic>.from(model.toMap());
    final safeMap = OfflinePendingService.mapToJsonSafe(rawMap);
    await _offlinePending.addPending(
      id: id,
      type: 'POST',
      collection: 'registeredExercises',
      data: jsonEncode(safeMap),
    );
    final merged = [...state.exercises, model];
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final pendingIds = {...state.pendingExerciseIds, id};
    emit(
      state.copyWith(
        exercises: merged,
        pendingExerciseIds: pendingIds,
        error: null,
      ),
    );
  }

  Future<void> deleteExercise(String id) async {
    if (state.pendingExerciseIds.contains(id)) {
      await _offlinePending.remove(id);
      final nextExercises = state.exercises.where((e) => e.id != id).toList();
      final nextPending = {...state.pendingExerciseIds}..remove(id);
      emit(state.copyWith(exercises: nextExercises, pendingExerciseIds: nextPending));
      return;
    }
    await _registeredExercises.delete(id);
  }

  Future<void> syncPendingExercise(String id) async {
    await _offlinePending.syncOne(id);
    final next = {...state.pendingExerciseIds}..remove(id);
    emit(state.copyWith(pendingExerciseIds: next));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
