import 'dart:async';
import 'dart:convert';

import 'package:equilibra_mobile/data/models/registered_medical_visit_model.dart';
import 'package:equilibra_mobile/data/services/offline_pending_service.dart';
import 'package:equilibra_mobile/data/services/network_service.dart';
import 'package:equilibra_mobile/data/services/registered_medical_visits_service.dart';
import 'package:equilibra_mobile/presentation/cubits/visitas_medicas_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VisitasMedicasCubit extends Cubit<VisitasMedicasState> {
  VisitasMedicasCubit({
    RegisteredMedicalVisitsService? service,
    OfflinePendingService? offlinePendingService,
    NetworkService? networkService,
  })  : _service = service ?? RegisteredMedicalVisitsService(),
        _offlinePending = offlinePendingService ?? OfflinePendingService(),
        _network = networkService ?? NetworkService(),
        super(VisitasMedicasState()) {
    _loadYear(state.selectedYear);
    _subscription = _service.watchAll().listen((all) {
      _filterAndEmitForYear(all, state.selectedYear);
    });
  }

  final RegisteredMedicalVisitsService _service;
  final OfflinePendingService _offlinePending;
  final NetworkService _network;
  StreamSubscription<List<RegisteredMedicalVisitModel>>? _subscription;

  Future<void> _mergePending(List<RegisteredMedicalVisitModel> fromFirestore) async {
    final pending = await _offlinePending.getByCollection(
      'registeredMedicalVisits',
      year: state.selectedYear,
    );
    final pendingIds = <String>{};
    final pendingList = <RegisteredMedicalVisitModel>[];
    for (final op in pending) {
      try {
        final map = OfflinePendingService.parseDataMap(op.data);
        pendingList.add(RegisteredMedicalVisitModel.fromMap(op.id, map));
        pendingIds.add(op.id);
      } catch (_) {}
    }
    final existingIds = fromFirestore.map((v) => v.id).toSet();
    final merged = [
      ...fromFirestore,
      ...pendingList.where((v) => !existingIds.contains(v.id)),
    ];
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    emit(state.copyWith(visits: merged, pendingVisitIds: pendingIds));
  }

  Future<void> _filterAndEmitForYear(
    List<RegisteredMedicalVisitModel> all,
    int year,
  ) async {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);
    final forYear = all
        .where((v) =>
            !v.createdAt.isBefore(start) && v.createdAt.isBefore(end))
        .toList();
    forYear.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _mergePending(forYear);
  }

  Future<void> _loadYear(int year) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final visits = await _service.getByYear(year);
      await _mergePending(visits);
      emit(state.copyWith(loading: false));
    } catch (e, _) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void setYear(int year) {
    if (year == state.selectedYear) return;
    emit(state.copyWith(selectedYear: year));
    _loadYear(year);
  }

  /// Recarga visitas del año (pull-to-refresh).
  Future<void> refresh() async => _loadYear(state.selectedYear);

  Future<void> registerVisit({
    required String doctorName,
    required String field,
    required String title,
    required String description,
  }) async {
    final hasNet = await _network.hasConnection();

    if (!hasNet) {
      await _saveVisitOffline(
        doctorName: doctorName,
        field: field,
        title: title,
        description: description,
      );
      return;
    }

    try {
      await _service.create(
        doctorName: doctorName,
        field: field,
        title: title,
        description: description,
      );
      final all = await _service.getAll();
      await _filterAndEmitForYear(all, state.selectedYear);
    } catch (e, _) {
      await _saveVisitOffline(
        doctorName: doctorName,
        field: field,
        title: title,
        description: description,
        error: e.toString(),
      );
    }
  }

  Future<void> _saveVisitOffline({
    required String doctorName,
    required String field,
    required String title,
    required String description,
    String? error,
  }) async {
    final uid = _service.currentUserId ?? '';
    if (uid.isEmpty) {
      emit(state.copyWith(error: error ?? 'Usuario no autenticado'));
      return;
    }
    final id = 'off_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final model = RegisteredMedicalVisitModel(
      id: id,
      userId: uid,
      doctorName: doctorName,
      field: field,
      title: title,
      description: description,
      createdAt: now,
    );
    final rawMap = Map<String, dynamic>.from(model.toMap());
    final safeMap = OfflinePendingService.mapToJsonSafe(rawMap);
    await _offlinePending.addPending(
      id: id,
      type: 'POST',
      collection: 'registeredMedicalVisits',
      data: jsonEncode(safeMap),
    );
    final merged = [...state.visits, model];
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final pendingIds = {...state.pendingVisitIds, id};
    emit(
      state.copyWith(
        visits: merged,
        pendingVisitIds: pendingIds,
        error: null,
      ),
    );
  }

  Future<void> deleteVisit(String id) async {
    if (state.pendingVisitIds.contains(id)) {
      await _offlinePending.remove(id);
      final nextVisits = state.visits.where((v) => v.id != id).toList();
      final nextPending = {...state.pendingVisitIds}..remove(id);
      emit(state.copyWith(visits: nextVisits, pendingVisitIds: nextPending));
      return;
    }
    await _service.delete(id);
  }

  Future<void> syncPendingVisit(String id) async {
    await _offlinePending.syncOne(id);
    final next = {...state.pendingVisitIds}..remove(id);
    emit(state.copyWith(pendingVisitIds: next));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
