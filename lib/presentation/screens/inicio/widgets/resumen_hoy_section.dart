import 'package:equilibra_mobile/presentation/screens/inicio/widgets/resumen_hoy_card.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Datos del resumen de hoy (desde los cubits).
class ResumenHoyData {
  const ResumenHoyData({
    required this.mealsCount,
    required this.exerciseMinutes,
    required this.sleepFormatted,
    this.lastVisitDoctor,
    this.lastVisitDate,
  });

  final int mealsCount;
  final int exerciseMinutes;
  final String sleepFormatted;

  /// Última cita: nombre del doctor (null si no hay).
  final String? lastVisitDoctor;

  /// Última cita: fecha formateada (ej. "15 Dic 2024").
  final String? lastVisitDate;
}

/// Sección "Resumen de hoy" con datos reales o placeholders.
class ResumenHoySection extends StatelessWidget {
  const ResumenHoySection({super.key, this.data});

  final ResumenHoyData? data;

  @override
  Widget build(BuildContext context) {
    final mealsCount = data?.mealsCount ?? 0;
    final exerciseMinutes = data?.exerciseMinutes ?? 0;
    final sleepFormatted = data?.sleepFormatted ?? '—';
    final lastDoctor = data?.lastVisitDoctor;
    final lastDate = data?.lastVisitDate;

    final exerciseText = exerciseMinutes >= 60
        ? '${exerciseMinutes ~/ 60}h ${exerciseMinutes % 60}m'
        : '${exerciseMinutes}m';

    final visitValue = lastDoctor != null && lastDoctor.isNotEmpty
        ? lastDoctor
        : '—';
    final visitSubtitle = lastDate ?? 'Sin citas';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Resumen de hoy',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ResumenHoyCard(
                        icon: Icons.restaurant,
                        label: 'Comidas',
                        value: '$mealsCount',
                        subtitle: 'Registradas',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ResumenHoyCard(
                        icon: Icons.fitness_center,
                        label: 'Ejercicio',
                        value: exerciseMinutes > 0 ? exerciseText : '—',
                        subtitle: 'Completado',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ResumenHoyCard(
                        icon: Icons.bed,
                        label: 'Sueño',
                        value: sleepFormatted,
                        subtitle: 'Total hoy',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ResumenHoyCard(
                        icon: Icons.medical_services,
                        label: 'Citas médicas',
                        value: visitValue,
                        subtitle: visitSubtitle,
                        smallValue: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
