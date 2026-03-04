import 'package:equilibra_mobile/presentation/cubits/alimentacion_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/alimentacion_state.dart';
import 'package:equilibra_mobile/presentation/screens/alimentacion/widgets/add_ingredient_sheet.dart';
import 'package:equilibra_mobile/presentation/screens/alimentacion/widgets/add_meal_sheet.dart';
import 'package:equilibra_mobile/presentation/screens/alimentacion/widgets/alimentacion_app_bar.dart';
import 'package:equilibra_mobile/presentation/screens/alimentacion/widgets/date_nav.dart';
import 'package:equilibra_mobile/presentation/screens/alimentacion/widgets/meals_list.dart';
import 'package:equilibra_mobile/presentation/screens/alimentacion/widgets/nutrition_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla Alimentación: fecha, resumen nutricional, lista de comidas.
class AlimentacionScreen extends StatelessWidget {
  const AlimentacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AlimentacionView();
  }
}

class _AlimentacionAppBarWrapper extends StatelessWidget
    implements PreferredSizeWidget {
  const _AlimentacionAppBarWrapper({required this.onAddMeal});

  final void Function(BuildContext context, AlimentacionState state) onAddMeal;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlimentacionCubit, AlimentacionState>(
      buildWhen: (a, b) => a.mealTypes != b.mealTypes,
      builder: (context, state) {
        return AlimentacionAppBar(
          onAdd: state.mealTypes.isEmpty
              ? null
              : () => onAddMeal(context, state),
        );
      },
    );
  }
}

class _AlimentacionView extends StatelessWidget {
  const _AlimentacionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _AlimentacionAppBarWrapper(onAddMeal: _onAddMeal),
      body: BlocBuilder<AlimentacionCubit, AlimentacionState>(
        builder: (context, state) {
          if (state.loading && state.meals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DateNav(
                  date: state.selectedDate,
                  onPrevious: () {
                    final d = state.selectedDate;
                    context.read<AlimentacionCubit>().setDate(
                      DateTime(d.year, d.month, d.day - 1),
                    );
                  },
                  onNext: () {
                    final d = state.selectedDate;
                    context.read<AlimentacionCubit>().setDate(
                      DateTime(d.year, d.month, d.day + 1),
                    );
                  },
                ),
                NutritionSummaryCard(
                  calories: state.totalKcal,
                  proteins: state.totalProteins,
                  carbs: state.totalCarbs,
                ),
                const SizedBox(height: 20),
                MealsList(
                  meals: state.meals,
                  onMealTap: (meal) => _onMealTap(context, state, meal.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onAddMeal(BuildContext context, AlimentacionState state) async {
    final ref = await showAddMealSheet(context, state.mealTypes);
    if (ref == null || !context.mounted) return;
    await context.read<AlimentacionCubit>().addMeal(ref);
  }

  Future<void> _onMealTap(
    BuildContext context,
    AlimentacionState state,
    String mealId,
  ) async {
    final result = await showAddIngredientSheet(
      context,
      state.defaultIngredients,
    );
    if (result == null || !context.mounted) return;
    await context.read<AlimentacionCubit>().addIngredientToMeal(
      mealId,
      result.ingredientId,
      result.quantity,
    );
  }
}
