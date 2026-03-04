import 'package:flutter/material.dart';
import 'package:equilibra_mobile/data/models/meal_type_model.dart';
import 'package:equilibra_mobile/data/models/registered_meal_model.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';

Future<MealTypeRef?> showAddMealSheet(
  BuildContext context,
  List<MealTypeModel> mealTypes,
) async {
  return showModalBottomSheet<MealTypeRef>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tipo de comida',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          ...mealTypes.map((t) {
            final color = _colorFromHex(t.color);
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(_iconFromSrc(t.iconSrc), color: color, size: 22),
              ),
              title: Text(t.name),
              onTap: () => Navigator.pop(context, MealTypeRef(
                id: t.id,
                name: t.name,
                iconSrc: t.iconSrc,
                color: t.color,
              )),
            );
          }),
        ],
      ),
    ),
  );
}

Color _colorFromHex(String hex) {
  if (hex.isEmpty || !hex.startsWith('#')) return AppColors.healthPrimary;
  try {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  } catch (_) {
    return AppColors.healthPrimary;
  }
}

IconData _iconFromSrc(String src) {
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
