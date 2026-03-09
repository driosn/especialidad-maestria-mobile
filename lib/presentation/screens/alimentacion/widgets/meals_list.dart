import 'package:equilibra_mobile/data/models/registered_meal_model.dart';
import 'package:equilibra_mobile/presentation/screens/alimentacion/widgets/meal_card.dart';
import 'package:flutter/material.dart';

class MealsList extends StatelessWidget {
  const MealsList({
    super.key,
    required this.meals,
    this.pendingMealIds = const {},
    this.onMealTap,
    this.onSyncTap,
  });

  final List<RegisteredMealModel> meals;
  final Set<String> pendingMealIds;
  final void Function(RegisteredMealModel meal)? onMealTap;
  final void Function(String mealId)? onSyncTap;

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No hay comidas registradas. Pulsa + para agregar.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        final isPendingSync = pendingMealIds.contains(meal.id);
        return MealCard(
          meal: meal,
          isPendingSync: isPendingSync,
          onTap: onMealTap != null ? () => onMealTap!(meal) : null,
          onSyncTap: isPendingSync && onSyncTap != null ? () => onSyncTap!(meal.id) : null,
        );
      },
    );
  }
}
