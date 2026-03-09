import 'package:equilibra_mobile/data/models/default_exercise_model.dart';
import 'package:equilibra_mobile/presentation/cubits/ejercicio_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/ejercicio_state.dart';
import 'package:equilibra_mobile/presentation/screens/ejercicio/widgets/ejercicio_date_nav.dart';
import 'package:equilibra_mobile/presentation/screens/ejercicio/widgets/ejercicio_summary_cards.dart';
import 'package:equilibra_mobile/presentation/screens/ejercicio/widgets/ejercicios_list.dart';
import 'package:equilibra_mobile/presentation/screens/ejercicio/widgets/register_exercise_sheet.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EjercicioScreen extends StatelessWidget {
  const EjercicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _EjercicioView();
  }
}

class _EjercicioView extends StatelessWidget {
  const _EjercicioView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Ejercicio',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<EjercicioCubit, EjercicioState>(
        builder: (context, state) {
          if (state.loading && state.exercises.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EjercicioDateNav(
                  date: state.selectedDate,
                  onPrevious: () {
                    final d = state.selectedDate;
                    context.read<EjercicioCubit>().setDate(
                      DateTime(d.year, d.month, d.day - 1),
                    );
                  },
                  onNext: () {
                    final d = state.selectedDate;
                    context.read<EjercicioCubit>().setDate(
                      DateTime(d.year, d.month, d.day + 1),
                    );
                  },
                ),
                const SizedBox(height: 16),
                EjercicioSummaryCards(
                  kcalBurned: state.totalKcal,
                  activeMinutes: state.totalDurationMinutes,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ejercicios registrados',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
                EjerciciosList(
                  exercises: state.exercises,
                  pendingExerciseIds: state.pendingExerciseIds,
                  onOptionsTap: (ex) => _showOptions(context, ex.id),
                  onSyncTap: (id) => _onSyncExerciseTap(context, id),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FilledButton.icon(
            onPressed: () => _onRegisterExercise(context),
            icon: const Icon(Icons.add, size: 22),
            label: const Text('Registrar ejercicio'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onRegisterExercise(BuildContext context) async {
    final state = context.read<EjercicioCubit>().state;
    final ok = await showRegisterExerciseSheet(
      context,
      state.defaultExercises,
      state.selectedDate,
      ({
        required DefaultExerciseModel exercise,
        required DateTime date,
        required num duration,
        required num distance,
        required num kcal,
        required num series,
        required num reps,
        required num weight,
      }) => context.read<EjercicioCubit>().registerExercise(
        exercise: exercise,
        date: date,
        duration: duration,
        distance: distance,
        kcal: kcal,
        series: series,
        reps: reps,
        weight: weight,
      ),
    );
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ejercicio registrado'),
          backgroundColor: AppColors.healthPrimary,
        ),
      );
    }
  }

  Future<void> _onSyncExerciseTap(BuildContext context, String exerciseId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sincronizar registro'),
        content: const Text('¿Quieres sincronizar este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sincronizar'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<EjercicioCubit>().syncPendingExercise(exerciseId);
    }
  }

  void _showOptions(BuildContext context, String exerciseId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<EjercicioCubit>().deleteExercise(exerciseId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
