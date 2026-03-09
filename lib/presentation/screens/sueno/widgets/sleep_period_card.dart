import 'package:flutter/material.dart';
import 'package:equilibra_mobile/data/models/registered_sleep_time_model.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';

class SleepPeriodCard extends StatelessWidget {
  const SleepPeriodCard({
    super.key,
    required this.period,
    this.isPendingSync = false,
    this.onOptionsTap,
    this.onSyncTap,
  });

  final RegisteredSleepTimeModel period;
  final bool isPendingSync;
  final VoidCallback? onOptionsTap;
  final VoidCallback? onSyncTap;

  @override
  Widget build(BuildContext context) {
    final isNight = period.startTimestamp.hour >= 20 || period.startTimestamp.hour < 6;
    final iconColor = isNight
        ? const Color(0xFF93C5FD)
        : const Color(0xFFFDBA74);

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
              color: iconColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isNight ? Icons.nightlight_round : Icons.wb_sunny_outlined,
              color: iconColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  period.durationFormatted,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Desde ${period.startTimeFormatted} · Hasta ${period.endTimeFormatted}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (isPendingSync && onSyncTap != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: onSyncTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off, size: 14, color: Colors.orange.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'Pendiente sinc.',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (onOptionsTap != null)
            IconButton(
              onPressed: onOptionsTap,
              icon: const Icon(Icons.more_vert),
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}
