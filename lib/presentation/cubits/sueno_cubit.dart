import 'dart:async';

import 'package:equilibra_mobile/data/models/registered_sleep_time_model.dart';
import 'package:equilibra_mobile/data/services/registered_sleep_times_service.dart';
import 'package:equilibra_mobile/presentation/cubits/sueno_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SuenoCubit extends Cubit<SuenoState> {
  SuenoCubit({
    RegisteredSleepTimesService? registeredSleepTimesService,
  })  : _service =
            registeredSleepTimesService ?? RegisteredSleepTimesService(),
        super(SuenoState()) {
    _subscription =
        _service.watchByDate(state.selectedDate).listen(_onSleepTimesUpdated);
  }

  final RegisteredSleepTimesService _service;
  StreamSubscription<List<RegisteredSleepTimeModel>>? _subscription;

  void _onSleepTimesUpdated(List<RegisteredSleepTimeModel> list) {
    emit(state.copyWith(sleepTimes: list));
  }

  void setDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    emit(state.copyWith(selectedDate: day, sleepTimes: []));
    _subscription?.cancel();
    _subscription = _service.watchByDate(day).listen(_onSleepTimesUpdated);
  }

  Future<void> registerSleepTime({
    required String name,
    required DateTime startTimestamp,
    required DateTime endTimestamp,
  }) async {
    try {
      await _service.create(
        name: name,
        startTimestamp: startTimestamp,
        endTimestamp: endTimestamp,
      );
      final updated = await _service.getByDate(state.selectedDate);
      emit(state.copyWith(sleepTimes: updated));
    } catch (e, _) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteSleepTime(String id) async {
    await _service.delete(id);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
