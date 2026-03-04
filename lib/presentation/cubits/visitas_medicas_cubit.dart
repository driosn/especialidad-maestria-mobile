import 'dart:async';

import 'package:equilibra_mobile/data/models/registered_medical_visit_model.dart';
import 'package:equilibra_mobile/data/services/registered_medical_visits_service.dart';
import 'package:equilibra_mobile/presentation/cubits/visitas_medicas_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VisitasMedicasCubit extends Cubit<VisitasMedicasState> {
  VisitasMedicasCubit({
    RegisteredMedicalVisitsService? service,
  })  : _service = service ?? RegisteredMedicalVisitsService(),
        super(VisitasMedicasState()) {
    _loadYear(state.selectedYear);
    _subscription = _service.watchAll().listen(_onVisitsUpdated);
  }

  final RegisteredMedicalVisitsService _service;
  StreamSubscription<List<RegisteredMedicalVisitModel>>? _subscription;

  void _onVisitsUpdated(List<RegisteredMedicalVisitModel> all) {
    _filterAndEmitForYear(all, state.selectedYear);
  }

  void _filterAndEmitForYear(
    List<RegisteredMedicalVisitModel> all,
    int year,
  ) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);
    final forYear = all
        .where((v) =>
            !v.createdAt.isBefore(start) && v.createdAt.isBefore(end))
        .toList();
    forYear.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    emit(state.copyWith(visits: forYear));
  }

  Future<void> _loadYear(int year) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final visits = await _service.getByYear(year);
      emit(state.copyWith(visits: visits, loading: false));
    } catch (e, _) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void setYear(int year) {
    if (year == state.selectedYear) return;
    emit(state.copyWith(selectedYear: year));
    _loadYear(year);
  }

  Future<void> registerVisit({
    required String doctorName,
    required String field,
    required String title,
    required String description,
  }) async {
    try {
      await _service.create(
        doctorName: doctorName,
        field: field,
        title: title,
        description: description,
      );
      final all = await _service.getAll();
      _filterAndEmitForYear(all, state.selectedYear);
    } catch (e, _) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteVisit(String id) async {
    await _service.delete(id);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
