import 'package:equilibra_mobile/data/models/registered_medical_visit_model.dart';

class VisitasMedicasState {
  VisitasMedicasState({
    int? year,
    this.visits = const [],
    this.pendingVisitIds = const {},
    this.loading = false,
    this.error,
  }) : selectedYear = year ?? DateTime.now().year;

  final int selectedYear;
  final List<RegisteredMedicalVisitModel> visits;
  final Set<String> pendingVisitIds;
  final bool loading;
  final String? error;

  int get totalVisits => visits.length;

  /// Número de especialidades distintas (por campo field).
  int get specialistsCount =>
      visits.map((v) => v.field).where((f) => f.isNotEmpty).toSet().length;

  /// Seguimientos: por defecto igual al total de visitas (todas cuentan como seguimiento).
  int get followUpsCount => visits.length;

  VisitasMedicasState copyWith({
    int? selectedYear,
    List<RegisteredMedicalVisitModel>? visits,
    Set<String>? pendingVisitIds,
    bool? loading,
    String? error,
  }) {
    return VisitasMedicasState(
      year: selectedYear ?? this.selectedYear,
      visits: visits ?? this.visits,
      pendingVisitIds: pendingVisitIds ?? this.pendingVisitIds,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}
