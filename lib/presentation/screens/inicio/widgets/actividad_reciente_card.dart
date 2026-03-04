import 'package:flutter/material.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';

/// Tarjeta de actividad reciente.
class ActividadRecienteCard extends StatelessWidget {
  const ActividadRecienteCard({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    required this.timeAgo,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String timeAgo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.healthPrimaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.healthPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$detail • $timeAgo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.healthPrimary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
