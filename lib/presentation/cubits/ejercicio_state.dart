import 'package:equilibra_mobile/data/models/default_exercise_model.dart';
import 'package:equilibra_mobile/data/models/registered_exercise_model.dart';

class EjercicioState {
  EjercicioState({
    DateTime? selectedDate,
    this.defaultExercises = const [],
    this.exercises = const [],
    this.loading = false,
    this.error,
  }) : selectedDate = selectedDate ?? DateTime.now();

  final DateTime selectedDate;
  final List<DefaultExerciseModel> defaultExercises;
  final List<RegisteredExerciseModel> exercises;
  final bool loading;
  final String? error;

  num get totalKcal =>
      exercises.fold<num>(0, (s, e) => s + e.kcal);
  num get totalDurationMinutes =>
      exercises.fold<num>(0, (s, e) => s + e.duration);

  EjercicioState copyWith({
    DateTime? selectedDate,
    List<DefaultExerciseModel>? defaultExercises,
    List<RegisteredExerciseModel>? exercises,
    bool? loading,
    String? error,
  }) {
    return EjercicioState(
      selectedDate: selectedDate ?? this.selectedDate,
      defaultExercises: defaultExercises ?? this.defaultExercises,
      exercises: exercises ?? this.exercises,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}
