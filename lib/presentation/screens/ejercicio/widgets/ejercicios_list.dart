import 'package:flutter/material.dart';
import 'package:equilibra_mobile/data/models/registered_exercise_model.dart';
import 'package:equilibra_mobile/presentation/screens/ejercicio/widgets/registered_exercise_card.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';

class EjerciciosList extends StatelessWidget {
  const EjerciciosList({
    super.key,
    required this.exercises,
    this.pendingExerciseIds = const {},
    this.onOptionsTap,
    this.onSyncTap,
  });

  final List<RegisteredExerciseModel> exercises;
  final Set<String> pendingExerciseIds;
  final void Function(RegisteredExerciseModel exercise)? onOptionsTap;
  final void Function(String exerciseId)? onSyncTap;

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No hay ejercicios registrados.\nPulsa "Registrar ejercicio" para agregar.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final ex = exercises[index];
        final isPendingSync = pendingExerciseIds.contains(ex.id);
        return RegisteredExerciseCard(
          exercise: ex,
          isPendingSync: isPendingSync,
          onOptionsTap: onOptionsTap != null ? () => onOptionsTap!(ex) : null,
          onSyncTap: isPendingSync && onSyncTap != null ? () => onSyncTap!(ex.id) : null,
        );
      },
    );
  }
}
