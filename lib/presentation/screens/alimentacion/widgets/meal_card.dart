import 'package:flutter/material.dart';
import 'package:equilibra_mobile/data/models/registered_meal_model.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.meal,
    this.onTap,
  });

  final RegisteredMealModel meal;
  final VoidCallback? onTap;

  static Color _colorFromHex(String hex) {
    if (hex.isEmpty || !hex.startsWith('#')) return AppColors.healthPrimary;
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (_) {
      return AppColors.healthPrimary;
    }
  }

  static IconData _iconFromSrc(String src) {
    switch (src) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'coffee':
        return Icons.coffee;
      case 'restaurant':
        return Icons.restaurant;
      case 'nightlight_round':
        return Icons.nightlight_round;
      default:
        return Icons.restaurant_menu;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFromHex(meal.mealType.color);
    final icon = _iconFromSrc(meal.mealType.iconSrc);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.mealType.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          Text(
                            '${meal.totalKcal.toInt()} cal',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
                if (meal.ingredients.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...meal.ingredients.map((i) => _IngredientRow(
                        name: i.name ?? 'Ingrediente',
                        quantity: i.quantity,
                        unitName: i.unitTypeName ?? '',
                        kcal: i.kcal ?? 0,
                      )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.name,
    required this.quantity,
    required this.unitName,
    required this.kcal,
  });

  final String name;
  final num quantity;
  final String unitName;
  final num kcal;

  @override
  Widget build(BuildContext context) {
    final qtyStr = unitName.isEmpty
        ? quantity.toString()
        : '$quantity $unitName';

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.healthPrimaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.egg, size: 18, color: AppColors.healthPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                Text(
                  qtyStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${kcal.toInt()} cal',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}
