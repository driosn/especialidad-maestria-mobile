import 'package:flutter/material.dart';
import 'package:equilibra_mobile/data/models/registered_sleep_time_model.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';

class SleepPeriodCard extends StatelessWidget {
  const SleepPeriodCard({
    super.key,
    required this.period,
    this.onOptionsTap,
  });

  final RegisteredSleepTimeModel period;
  final VoidCallback? onOptionsTap;

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
