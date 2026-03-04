import 'package:flutter/material.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';

class TotalSleepCard extends StatelessWidget {
  const TotalSleepCard({
    super.key,
    required this.totalFormatted,
    required this.periodCount,
    this.title = 'Total de sueño hoy',
  });

  final String totalFormatted;
  final int periodCount;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.sleepGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.sleepPrimary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                totalFormatted,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                periodCount == 1
                    ? '1 período de descanso'
                    : '$periodCount períodos de descanso',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.show_chart,
              color: Colors.white.withValues(alpha: 0.5),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
