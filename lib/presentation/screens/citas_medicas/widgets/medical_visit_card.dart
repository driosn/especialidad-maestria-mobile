import 'package:flutter/material.dart';
import 'package:equilibra_mobile/data/models/registered_medical_visit_model.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';

/// Colores por especialidad (icono del card).
Color _colorForField(String field) {
  final f = field.toLowerCase();
  if (f.contains('general') || f.contains('medicina')) return AppColors.accent;
  if (f.contains('oftalm') || f.contains('ojo')) return AppColors.sleepPrimary;
  if (f.contains('cardio') || f.contains('corazón')) return const Color(0xFFEF4444);
  if (f.contains('odont') || f.contains('dental') || f.contains('diente')) return AppColors.healthPrimary;
  if (f.contains('derm')) return const Color(0xFFF97316);
  return AppColors.primary;
}

IconData _iconForField(String field) {
  final f = field.toLowerCase();
  if (f.contains('general') || f.contains('medicina')) return Icons.medical_services;
  if (f.contains('oftalm') || f.contains('ojo')) return Icons.remove_red_eye;
  if (f.contains('cardio')) return Icons.favorite;
  if (f.contains('odont') || f.contains('dental')) return Icons.health_and_safety;
  if (f.contains('derm')) return Icons.face;
  return Icons.medical_services;
}

class MedicalVisitCard extends StatelessWidget {
  const MedicalVisitCard({
    super.key,
    required this.visit,
    this.onOptionsTap,
  });

  final RegisteredMedicalVisitModel visit;
  final VoidCallback? onOptionsTap;

  @override
  Widget build(BuildContext context) {
    final color = _colorForField(visit.field);
    final day = visit.createdAt.day;
    final month = _shortMonth(visit.createdAt.month);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconForField(visit.field), color: color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.doctorName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                if (visit.field.isNotEmpty)
                  Text(
                    visit.field,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                if (visit.title.isNotEmpty || visit.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.healthPrimaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: AppColors.healthPrimary),
                      const SizedBox(width: 4),
                      Text(
                        'Completada',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.healthPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$day $month',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              if (onOptionsTap != null) ...[
                const SizedBox(height: 8),
                IconButton(
                  onPressed: onOptionsTap,
                  icon: const Icon(Icons.more_vert),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String get _subtitle {
    if (visit.title.isNotEmpty && visit.description.isNotEmpty) {
      return '${visit.title} - ${visit.description}';
    }
    return visit.title.isNotEmpty ? visit.title : visit.description;
  }

  static String _shortMonth(int month) {
    const m = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return m[month - 1];
  }
}
