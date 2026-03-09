import 'package:equilibra_mobile/data/models/registered_exercise_model.dart';
import 'package:equilibra_mobile/data/models/registered_meal_model.dart';
import 'package:equilibra_mobile/data/models/registered_medical_visit_model.dart';
import 'package:equilibra_mobile/data/models/registered_sleep_time_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equilibra_mobile/presentation/cubits/alimentacion_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/alimentacion_state.dart';
import 'package:equilibra_mobile/presentation/cubits/ejercicio_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/ejercicio_state.dart';
import 'package:equilibra_mobile/presentation/cubits/sueno_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/sueno_state.dart';
import 'package:equilibra_mobile/presentation/cubits/visitas_medicas_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/visitas_medicas_state.dart';
import 'package:equilibra_mobile/presentation/screens/inicio/widgets/actividad_reciente_section.dart';
import 'package:equilibra_mobile/presentation/screens/inicio/widgets/inicio_banner.dart';
import 'package:equilibra_mobile/presentation/screens/inicio/widgets/inicio_header.dart';
import 'package:equilibra_mobile/presentation/screens/inicio/widgets/resumen_hoy_section.dart';

/// Dashboard Inicio: resumen y actividad reciente con datos reales.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key, this.onOpenProfile});

  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocBuilder<AlimentacionCubit, AlimentacionState>(
          buildWhen: (_, __) => true,
          builder: (context, alimentacion) {
            return BlocBuilder<EjercicioCubit, EjercicioState>(
              buildWhen: (_, __) => true,
              builder: (context, ejercicio) {
                return BlocBuilder<SuenoCubit, SuenoState>(
                  buildWhen: (_, __) => true,
                  builder: (context, sueno) {
                    return BlocBuilder<VisitasMedicasCubit, VisitasMedicasState>(
                      buildWhen: (_, __) => true,
                      builder: (context, visitas) {
                        final lastVisit = visitas.visits.isNotEmpty
                            ? visitas.visits.first
                            : null;
                        final resumenData = ResumenHoyData(
                          mealsCount: alimentacion.meals.length,
                          exerciseMinutes: ejercicio.totalDurationMinutes.toInt(),
                          sleepFormatted: sueno.totalDurationFormatted,
                          lastVisitDoctor: lastVisit?.doctorName,
                          lastVisitDate: lastVisit != null
                              ? _formatVisitDate(lastVisit.createdAt)
                              : null,
                        );
                        final activityItems = _buildRecentActivity(
                          alimentacion.meals,
                          ejercicio.exercises,
                          sueno.sleepTimes,
                          visitas.visits,
                        );
                        return RefreshIndicator(
                          onRefresh: () async {
                            await context.read<AlimentacionCubit>().refresh();
                            await context.read<EjercicioCubit>().refresh();
                            await context.read<SuenoCubit>().refresh();
                            await context.read<VisitasMedicasCubit>().refresh();
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                InicioHeader(
                                  onProfileTap: onOpenProfile,
                                ),
                                const InicioBanner(),
                                ResumenHoySection(data: resumenData),
                                const SizedBox(height: 24),
                                ActividadRecienteSection(items: activityItems),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  static List<ActividadRecienteItem> _buildRecentActivity(
    List<RegisteredMealModel> meals,
    List<RegisteredExerciseModel> exercises,
    List<RegisteredSleepTimeModel> sleepTimes,
    List<RegisteredMedicalVisitModel> visits,
  ) {
    final now = DateTime.now();
    final entries = <({DateTime at, ActividadRecienteItem item})>[];

    for (final m in meals) {
      entries.add((
        at: m.createdAt,
        item: ActividadRecienteItem(
          icon: Icons.restaurant,
          title: '${m.mealType.name} registrado',
          detail: '${m.totalKcal.toInt()} kcal',
          timeAgo: _timeAgo(now, m.createdAt),
        ),
      ));
    }
    for (final e in exercises) {
      entries.add((
        at: e.createdAt,
        item: ActividadRecienteItem(
          icon: Icons.fitness_center,
          title: e.exerciseName,
          detail: '${e.duration.toInt()} min • ${e.kcal.toInt()} kcal',
          timeAgo: _timeAgo(now, e.createdAt),
        ),
      ));
    }
    for (final s in sleepTimes) {
      entries.add((
        at: s.endTimestamp,
        item: ActividadRecienteItem(
          icon: Icons.bed,
          title: 'Sueño: ${s.name}',
          detail: s.durationFormatted,
          timeAgo: _timeAgo(now, s.endTimestamp),
        ),
      ));
    }
    for (final v in visits.take(3)) {
      entries.add((
        at: v.createdAt,
        item: ActividadRecienteItem(
          icon: Icons.medical_services,
          title: 'Visita: ${v.doctorName}',
          detail: v.field,
          timeAgo: _timeAgo(now, v.createdAt),
        ),
      ));
    }

    entries.sort((a, b) => b.at.compareTo(a.at));
    return entries.take(5).map((e) => e.item).toList();
  }

  static String _formatVisitDate(DateTime d) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static String _timeAgo(DateTime now, DateTime then) {
    final d = now.difference(then);
    if (d.inMinutes < 1) return 'Ahora';
    if (d.inMinutes < 60) return 'Hace ${d.inMinutes} min';
    if (d.inHours < 24) return 'Hace ${d.inHours}h';
    if (d.inDays == 1) return 'Ayer';
    if (d.inDays < 7) return 'Hace ${d.inDays} días';
    return 'Hace ${d.inDays ~/ 7} sem';
  }
}
