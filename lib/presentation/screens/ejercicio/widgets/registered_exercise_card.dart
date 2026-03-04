import 'package:flutter/material.dart';
import 'package:equilibra_mobile/data/models/registered_exercise_model.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';

class RegisteredExerciseCard extends StatelessWidget {
  const RegisteredExerciseCard({
    super.key,
    required this.exercise,
    this.onOptionsTap,
  });

  final RegisteredExerciseModel exercise;
  final VoidCallback? onOptionsTap;

  @override
  Widget build(BuildContext context) {
    final color = exercise.isCardio
        ? AppColors.healthPrimary
        : const Color(0xFF3B82F6);
    final timeStr = _formatTime(exercise.createdAt);

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
            child: Icon(
              exercise.isCardio ? Icons.directions_run : Icons.fitness_center,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                Text(
                  timeStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: _buildMetrics(context, color),
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

  List<Widget> _buildMetrics(BuildContext context, Color color) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        );
    if (exercise.isPeso) {
      return [
        if (exercise.series > 0) Text('${exercise.series.toInt()} Series', style: style),
        if (exercise.reps > 0) Text('${exercise.reps.toInt()} Reps', style: style),
        if (exercise.weight > 0) Text('${exercise.weight.toInt()}kg Peso', style: style),
      ];
    }
    return [
      if (exercise.duration > 0) Text('${exercise.duration.toInt()} Min', style: style),
      if (exercise.distance > 0) Text('${(exercise.distance / 1000).toStringAsFixed(1)}km Dist.', style: style),
      if (exercise.kcal > 0) Text('${exercise.kcal.toInt()} Cal', style: style),
    ];
  }

  String _formatTime(DateTime d) {
    final h = d.hour;
    final m = d.minute;
    final am = h < 12;
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${hour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} ${am ? 'AM' : 'PM'}';
  }
}
