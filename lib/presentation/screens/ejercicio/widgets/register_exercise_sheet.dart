import 'package:flutter/material.dart';
import 'package:equilibra_mobile/data/models/default_exercise_model.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';

Future<bool> showRegisterExerciseSheet(
  BuildContext context,
  List<DefaultExerciseModel> exercises,
  DateTime selectedDate,
  void Function({
    required DefaultExerciseModel exercise,
    required DateTime date,
    required num duration,
    required num distance,
    required num kcal,
    required num series,
    required num reps,
    required num weight,
  }) onRegister,
) async {
  if (exercises.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pulsa el FAB de prueba y elige "Cargar ejercicios"'),
        ),
      );
    }
    return false;
  }

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _RegisterExerciseSheetContent(
      exercises: exercises,
      selectedDate: selectedDate,
      onRegister: onRegister,
    ),
  ).then((result) => result ?? false);
}

class _RegisterExerciseSheetContent extends StatefulWidget {
  const _RegisterExerciseSheetContent({
    required this.exercises,
    required this.selectedDate,
    required this.onRegister,
  });

  final List<DefaultExerciseModel> exercises;
  final DateTime selectedDate;
  final void Function({
    required DefaultExerciseModel exercise,
    required DateTime date,
    required num duration,
    required num distance,
    required num kcal,
    required num series,
    required num reps,
    required num weight,
  }) onRegister;

  @override
  State<_RegisterExerciseSheetContent> createState() =>
      _RegisterExerciseSheetContentState();
}

class _RegisterExerciseSheetContentState
    extends State<_RegisterExerciseSheetContent> {
  late final TextEditingController searchController;
  late final TextEditingController durationController;
  late final TextEditingController distanceController;
  late final TextEditingController seriesController;
  late final TextEditingController repsController;
  late final TextEditingController weightController;

  DefaultExerciseModel? selected;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    durationController = TextEditingController();
    distanceController = TextEditingController();
    seriesController = TextEditingController();
    repsController = TextEditingController();
    weightController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    durationController.dispose();
    distanceController.dispose();
    seriesController.dispose();
    repsController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.exercises;
    final selectedDate = widget.selectedDate;
    final onRegister = widget.onRegister;
    final filtered = searchQuery.trim().isEmpty
        ? exercises
        : exercises
            .where((e) => e.name
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context, false),
                        icon: const Icon(Icons.close),
                        color: AppColors.textSecondary,
                      ),
                      Expanded(
                        child: Text(
                          'Registrar ejercicio',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar ejercicio...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.hint),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (v) => setState(() => searchQuery = v),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                if (selected == null)
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final ex = filtered[index];
                        final color = ex.isCardio
                            ? AppColors.healthPrimary
                            : const Color(0xFF3B82F6);
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              ex.isCardio ? Icons.directions_run : Icons.fitness_center,
                              color: color,
                              size: 22,
                            ),
                          ),
                          title: Text(ex.name),
                          subtitle: Text(
                            ex.type,
                            style: TextStyle(color: color, fontSize: 12),
                          ),
                          onTap: () => setState(() {
                            selected = ex;
                            // Cardio: duración del ejercicio o vacío. Peso: 10 min por defecto.
                            if (ex.isCardio) {
                              durationController.text = ex.duration > 0 ? ex.duration.toInt().toString() : '';
                            } else {
                              durationController.text = '10'; // Peso: 10 min por defecto
                            }
                            distanceController.text = ex.distance > 0 ? (ex.distance / 1000).toStringAsFixed(1) : '';
                            seriesController.text = ex.series > 0 ? ex.series.toInt().toString() : '';
                            repsController.text = ex.reps > 0 ? ex.reps.toInt().toString() : '';
                            weightController.text = ex.weight > 0 ? ex.weight.toInt().toString() : '';
                          }),
                        );
                      },
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                selected!.isCardio ? Icons.directions_run : Icons.fitness_center,
                                color: selected!.isCardio ? AppColors.healthPrimary : const Color(0xFF3B82F6),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selected!.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => setState(() => selected = null),
                                child: const Text('Cambiar'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (selected!.isCardio) ...[
                            _buildNumberField(
                              context,
                              controller: durationController,
                              label: 'Duración (minutos)',
                              hint: '30',
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 12),
                            _buildNumberField(
                              context,
                              controller: distanceController,
                              label: 'Distancia (km)',
                              hint: '5.2',
                            ),
                            const SizedBox(height: 12),
                            _buildEstimatedKcal(context, selected!, durationController, defaultDuration: 30),
                          ] else ...[
                            _buildNumberField(
                              context,
                              controller: durationController,
                              label: 'Duración (minutos)',
                              hint: '10',
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 12),
                            _buildEstimatedKcal(context, selected!, durationController, defaultDuration: 10),
                            const SizedBox(height: 12),
                            _buildNumberField(
                              context,
                              controller: seriesController,
                              label: 'Series',
                              hint: '3',
                            ),
                            const SizedBox(height: 12),
                            _buildNumberField(
                              context,
                              controller: repsController,
                              label: 'Repeticiones por serie',
                              hint: '12',
                            ),
                            const SizedBox(height: 12),
                            _buildNumberField(
                              context,
                              controller: weightController,
                              label: 'Peso (kg)',
                              hint: '80',
                            ),
                          ],
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: () {
                              final ex = selected!;
                              const defaultDuration = 10;
                              final durationVal = num.tryParse(durationController.text);
                              final duration = (durationVal != null && durationVal > 0)
                                  ? durationVal
                                  : defaultDuration;
                              final kcal = ex.kcalForDuration(duration);
                              if (ex.isCardio) {
                                final distanceKm = num.tryParse(distanceController.text) ?? 0;
                                onRegister(
                                  exercise: ex,
                                  date: selectedDate,
                                  duration: duration,
                                  distance: distanceKm * 1000,
                                  kcal: kcal,
                                  series: 0,
                                  reps: 0,
                                  weight: 0,
                                );
                              } else {
                                final series = num.tryParse(seriesController.text) ?? 0;
                                final reps = num.tryParse(repsController.text) ?? 0;
                                final weight = num.tryParse(weightController.text) ?? 0;
                                onRegister(
                                  exercise: ex,
                                  date: selectedDate,
                                  duration: duration,
                                  distance: 0,
                                  kcal: kcal,
                                  series: series,
                                  reps: reps,
                                  weight: weight,
                                );
                              }
                              Navigator.pop(context, true);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.healthPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Registrar'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
  }
}

Widget _buildNumberField(
  BuildContext context, {
  required TextEditingController controller,
  required String label,
  required String hint,
  void Function(String)? onChanged,
}) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

Widget _buildEstimatedKcal(
  BuildContext context,
  DefaultExerciseModel exercise,
  TextEditingController durationController, {
  num defaultDuration = 10,
}) {
  final durationVal = num.tryParse(durationController.text);
  final duration = (durationVal != null && durationVal > 0)
      ? durationVal
      : defaultDuration;
  final kcal = exercise.kcalForDuration(duration).round();
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(Icons.local_fire_department, color: AppColors.healthPrimary, size: 20),
        const SizedBox(width: 8),
        Text(
          'Calorías estimadas: $kcal kcal',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    ),
  );
}
