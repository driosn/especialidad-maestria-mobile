import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';

class NutritionSummaryCard extends StatelessWidget {
  const NutritionSummaryCard({
    super.key,
    required this.calories,
    required this.proteins,
    required this.carbs,
  });

  final num calories;
  final num proteins;
  final num carbs;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Metric(
            value: _formatNumber(calories),
            label: 'Calorías',
            color: AppColors.healthPrimary,
          ),
          _Metric(
            value: '${proteins.toInt()}g',
            label: 'Proteínas',
            color: const Color(0xFF3B82F6),
          ),
          _Metric(
            value: '${carbs.toInt()}g',
            label: 'Carbohidratos',
            color: const Color(0xFFF97316),
          ),
        ],
      ),
    );
  }

  String _formatNumber(num n) {
    // if (n >= 1000) {
    // return '${(n / 1000).toStringAsFixed(1).replaceAll('.0', '')},${(n % 1000).toStringAsFixed(0).padLeft(3, '0')}';
    // }
    return n.toInt().toString();
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
