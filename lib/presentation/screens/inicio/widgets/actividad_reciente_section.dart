import 'package:flutter/material.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:equilibra_mobile/presentation/screens/inicio/widgets/actividad_reciente_card.dart';

/// Un ítem de actividad reciente para el inicio.
class ActividadRecienteItem {
  const ActividadRecienteItem({
    required this.icon,
    required this.title,
    required this.detail,
    required this.timeAgo,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String timeAgo;
}

/// Sección "Actividad reciente" con datos reales o vacía.
class ActividadRecienteSection extends StatelessWidget {
  const ActividadRecienteSection({
    super.key,
    this.items = const [],
  });

  final List<ActividadRecienteItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Actividad reciente',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Aún no hay actividad. Registra comidas, ejercicio o sueño en sus pestañas.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                )
              : Column(
                  children: items
                      .map(
                        (item) => ActividadRecienteCard(
                          icon: item.icon,
                          title: item.title,
                          detail: item.detail,
                          timeAgo: item.timeAgo,
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }
}
