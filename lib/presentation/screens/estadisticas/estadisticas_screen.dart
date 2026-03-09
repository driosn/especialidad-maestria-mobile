import 'package:equilibra_mobile/data/models/registered_exercise_model.dart';
import 'package:equilibra_mobile/data/models/registered_meal_model.dart';
import 'package:equilibra_mobile/data/models/registered_sleep_time_model.dart';
import 'package:equilibra_mobile/data/services/registered_exercises_service.dart';
import 'package:equilibra_mobile/data/services/registered_meals_service.dart';
import 'package:equilibra_mobile/data/services/registered_sleep_times_service.dart';
import 'package:equilibra_mobile/di/injection.dart';
import 'package:equilibra_mobile/presentation/screens/estadisticas/widgets/ejercicios_pie_chart.dart';
import 'package:equilibra_mobile/presentation/screens/estadisticas/widgets/nutrition_line_chart.dart';
import 'package:equilibra_mobile/presentation/screens/estadisticas/widgets/sleep_week_line_chart.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Pantalla de estadísticas mensuales: gráfico de ejercicios, nutrición y sueño.
class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  List<RegisteredExerciseModel> _exercises = [];
  List<RegisteredMealModel> _meals7 = [];
  List<RegisteredMealModel> _meals30 = [];
  List<RegisteredSleepTimeModel> _sleepWeek = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final exercisesService = getIt<RegisteredExercisesService>();
      final mealsService = getIt<RegisteredMealsService>();
      final sleepService = getIt<RegisteredSleepTimesService>();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Últimos 7 días de ejercicios (para torta por tipo/nombre)
      final exercises = <RegisteredExerciseModel>[];
      for (var i = 0; i < 7; i++) {
        final d = today.subtract(Duration(days: i));
        exercises.addAll(await exercisesService.getByDate(d));
      }

      // Comidas: semana actual (Lun–Dom) para 7D y últimos 30 días para 30D
      final monday = today.subtract(Duration(days: today.weekday - 1));
      final meals7 = <RegisteredMealModel>[];
      final meals30 = <RegisteredMealModel>[];
      for (var i = 0; i < 7; i++) {
        meals7.addAll(
          await mealsService.getByDate(monday.add(Duration(days: i))),
        );
      }
      for (var i = 0; i < 30; i++) {
        meals30.addAll(
          await mealsService.getByDate(today.subtract(Duration(days: i))),
        );
      }

      // Sueño semana actual (Lun a Dom)
      final sleepWeek = <RegisteredSleepTimeModel>[];
      for (var i = 0; i < 7; i++) {
        sleepWeek.addAll(
          await sleepService.getByDate(monday.add(Duration(days: i))),
        );
      }

      if (mounted) {
        setState(() {
          _exercises = exercises;
          _meals7 = meals7;
          _meals30 = meals30;
          _sleepWeek = sleepWeek;
          _loading = false;
        });
      }
    } catch (e, _) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Estadísticas semanales',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _load,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EjerciciosPieChart(exercises: _exercises),
                    const SizedBox(height: 24),
                    NutritionLineChart(
                      meals7: _meals7,
                      meals30: _meals30,
                      today: DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SleepWeekLineChart(sleepPeriods: _sleepWeek),
                  ],
                ),
              ),
            ),
    );
  }
}
