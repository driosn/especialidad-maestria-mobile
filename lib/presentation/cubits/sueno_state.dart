import 'package:equilibra_mobile/data/models/registered_sleep_time_model.dart';

class SuenoState {
  SuenoState({
    DateTime? selectedDate,
    this.sleepTimes = const [],
    this.loading = false,
    this.error,
  }) : selectedDate = selectedDate ?? DateTime.now();

  final DateTime selectedDate;
  final List<RegisteredSleepTimeModel> sleepTimes;
  final bool loading;
  final String? error;

  /// Total minutos de sueño en el día seleccionado.
  int get totalDurationMinutes =>
      sleepTimes.fold<int>(0, (s, e) => s + e.durationMinutes);

  /// Total formateado (ej. "9h 45m").
  String get totalDurationFormatted {
    final total = totalDurationMinutes;
    final h = total ~/ 60;
    final m = total % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  SuenoState copyWith({
    DateTime? selectedDate,
    List<RegisteredSleepTimeModel>? sleepTimes,
    bool? loading,
    String? error,
  }) {
    return SuenoState(
      selectedDate: selectedDate ?? this.selectedDate,
      sleepTimes: sleepTimes ?? this.sleepTimes,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}
