import 'dart:async';
import 'dart:convert';

import 'package:equilibra_mobile/data/models/registered_sleep_time_model.dart';
import 'package:equilibra_mobile/data/services/offline_pending_service.dart';
import 'package:equilibra_mobile/data/services/network_service.dart';
import 'package:equilibra_mobile/data/services/registered_sleep_times_service.dart';
import 'package:equilibra_mobile/presentation/cubits/sueno_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SuenoCubit extends Cubit<SuenoState> {
  SuenoCubit({
    RegisteredSleepTimesService? registeredSleepTimesService,
    OfflinePendingService? offlinePendingService,
    NetworkService? networkService,
  })  : _service =
            registeredSleepTimesService ?? RegisteredSleepTimesService(),
        _offlinePending = offlinePendingService ?? OfflinePendingService(),
        _network = networkService ?? NetworkService(),
        super(SuenoState()) {
    _subscription =
        _service.watchByDate(state.selectedDate).listen(_onSleepTimesUpdated);
  }

  final RegisteredSleepTimesService _service;
  final OfflinePendingService _offlinePending;
  final NetworkService _network;
  StreamSubscription<List<RegisteredSleepTimeModel>>? _subscription;

  Future<void> _mergePending(List<RegisteredSleepTimeModel> fromFirestore) async {
    final pending = await _offlinePending.getByCollection(
      'registeredSleepTimes',
      date: state.selectedDate,
    );
    final pendingIds = <String>{};
    final pendingList = <RegisteredSleepTimeModel>[];
    for (final op in pending) {
      try {
        final map = OfflinePendingService.parseDataMap(op.data);
        pendingList.add(RegisteredSleepTimeModel.fromMap(op.id, map));
        pendingIds.add(op.id);
      } catch (_) {}
    }
    final existingIds = fromFirestore.map((s) => s.id).toSet();
    final merged = [
      ...fromFirestore,
      ...pendingList.where((s) => !existingIds.contains(s.id)),
    ];
    merged.sort((a, b) => a.startTimestamp.compareTo(b.startTimestamp));
    emit(state.copyWith(sleepTimes: merged, pendingSleepIds: pendingIds));
  }

  void _onSleepTimesUpdated(List<RegisteredSleepTimeModel> list) {
    _mergePending(list);
  }

  void setDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    emit(state.copyWith(selectedDate: day, sleepTimes: []));
    _subscription?.cancel();
    _subscription = _service.watchByDate(day).listen(_onSleepTimesUpdated);
  }

  /// Recarga períodos de sueño del día (pull-to-refresh).
  Future<void> refresh() async {
    final list = await _service.getByDate(state.selectedDate);
    await _mergePending(list);
  }

  Future<void> registerSleepTime({
    required String name,
    required DateTime startTimestamp,
    required DateTime endTimestamp,
  }) async {
    final hasNet = await _network.hasConnection();

    if (!hasNet) {
      await _saveSleepOffline(
        name: name,
        startTimestamp: startTimestamp,
        endTimestamp: endTimestamp,
      );
      return;
    }

    try {
      await _service.create(
        name: name,
        startTimestamp: startTimestamp,
        endTimestamp: endTimestamp,
      );
      final updated = await _service.getByDate(state.selectedDate);
      emit(state.copyWith(sleepTimes: updated));
    } catch (e, _) {
      await _saveSleepOffline(
        name: name,
        startTimestamp: startTimestamp,
        endTimestamp: endTimestamp,
        error: e.toString(),
      );
    }
  }

  Future<void> _saveSleepOffline({
    required String name,
    required DateTime startTimestamp,
    required DateTime endTimestamp,
    String? error,
  }) async {
    final uid = _service.currentUserId ?? '';
    if (uid.isEmpty) {
      emit(state.copyWith(error: error ?? 'Usuario no autenticado'));
      return;
    }
    final id = 'off_${DateTime.now().millisecondsSinceEpoch}';
    final model = RegisteredSleepTimeModel(
      id: id,
      userId: uid,
      name: name,
      startTimestamp: startTimestamp,
      endTimestamp: endTimestamp,
      createdAt: DateTime.now(),
    );
    final rawMap = Map<String, dynamic>.from(model.toMap());
    final safeMap = OfflinePendingService.mapToJsonSafe(rawMap);
    await _offlinePending.addPending(
      id: id,
      type: 'POST',
      collection: 'registeredSleepTimes',
      data: jsonEncode(safeMap),
    );
    final merged = [...state.sleepTimes, model];
    merged.sort((a, b) => a.startTimestamp.compareTo(b.startTimestamp));
    final pendingIds = {...state.pendingSleepIds, id};
    emit(
      state.copyWith(
        sleepTimes: merged,
        pendingSleepIds: pendingIds,
        error: null,
      ),
    );
  }

  Future<void> deleteSleepTime(String id) async {
    if (state.pendingSleepIds.contains(id)) {
      await _offlinePending.remove(id);
      final nextSleep = state.sleepTimes.where((s) => s.id != id).toList();
      final nextPending = {...state.pendingSleepIds}..remove(id);
      emit(state.copyWith(sleepTimes: nextSleep, pendingSleepIds: nextPending));
      return;
    }
    await _service.delete(id);
  }

  Future<void> syncPendingSleep(String id) async {
    await _offlinePending.syncOne(id);
    final next = {...state.pendingSleepIds}..remove(id);
    emit(state.copyWith(pendingSleepIds: next));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
