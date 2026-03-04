import 'package:equilibra_mobile/data/models/registered_meal_model.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Datos diarios para el gráfico de nutrición.
class _DayNutrient {
  _DayNutrient({
    required this.label,
    required this.kcal,
    required this.carbs,
    required this.proteins,
  });
  final String label;
  final double kcal;
  final double carbs;
  final double proteins;
}

/// Gráfico de líneas: Progreso semanal/mensual (Calorías, Carbohidratos, Proteínas).
class NutritionLineChart extends StatefulWidget {
  const NutritionLineChart({
    super.key,
    required this.meals7,
    required this.meals30,
    required this.today,
  });

  final List<RegisteredMealModel> meals7;
  final List<RegisteredMealModel> meals30;
  final DateTime today;

  @override
  State<NutritionLineChart> createState() => _NutritionLineChartState();
}

class _NutritionLineChartState extends State<NutritionLineChart> {
  bool _is7Days = true;

  List<_DayNutrient> _aggregateByDay(List<RegisteredMealModel> meals, bool weekMode) {
    final map = <DateTime, ({double kcal, double carbs, double proteins})>{};
    for (final m in meals) {
      final d = DateTime(m.date.year, m.date.month, m.date.day);
      final current = map[d] ?? (kcal: 0.0, carbs: 0.0, proteins: 0.0);
      map[d] = (
        kcal: current.kcal + m.totalKcal.toDouble(),
        carbs: current.carbs + m.totalCarbs.toDouble(),
        proteins: current.proteins + m.totalProteins.toDouble(),
      );
    }

    const weekLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    if (weekMode) {
      final monday = widget.today.subtract(Duration(days: widget.today.weekday - 1));
      return List.generate(7, (i) {
        final d = monday.add(Duration(days: i));
        final v = map[d] ?? (kcal: 0.0, carbs: 0.0, proteins: 0.0);
        return _DayNutrient(
          label: weekLabels[i],
          kcal: v.kcal,
          carbs: v.carbs,
          proteins: v.proteins,
        );
      });
    }

    final days = map.keys.toList()..sort();
    if (days.isEmpty) {
      return List.generate(30, (i) {
        final d = widget.today.subtract(Duration(days: 29 - i));
        return _DayNutrient(
          label: '${d.day}',
          kcal: 0,
          carbs: 0,
          proteins: 0,
        );
      });
    }
    final start = widget.today.subtract(const Duration(days: 29));
    return List.generate(30, (i) {
      final d = start.add(Duration(days: i));
      final v = map[d] ?? (kcal: 0.0, carbs: 0.0, proteins: 0.0);
      return _DayNutrient(
        label: '${d.day}',
        kcal: v.kcal,
        carbs: v.carbs,
        proteins: v.proteins,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _is7Days
        ? _aggregateByDay(widget.meals7, true)
        : _aggregateByDay(widget.meals30, false);

    final maxKcal = data.map((e) => e.kcal).fold<double>(0, (a, b) => a > b ? a : b);
    final maxCarbs = data.map((e) => e.carbs).fold<double>(0, (a, b) => a > b ? a : b);
    final maxProteins = data.map((e) => e.proteins).fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = [maxKcal, maxCarbs, maxProteins].reduce((a, b) => a > b ? a : b);
    final maxVal = maxY < 1 ? 1.0 : maxY * 1.2;

    final spotsKcal = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.kcal)).toList();
    final spotsCarbs = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.carbs)).toList();
    final spotsProteins = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.proteins)).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Progreso Semanal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const Spacer(),
              _toggle(context, '7D', true),
              const SizedBox(width: 8),
              _toggle(context, '30D', false),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border.withValues(alpha: 0.5)),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, meta) => Text(
                        v >= 1000 ? '${(v ~/ 1000)}k' : v.toInt().toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i >= 0 && i < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              data[i].label,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: maxVal,
                lineBarsData: [
                  LineChartBarData(
                    spots: spotsKcal,
                    isCurved: true,
                    color: AppColors.accent,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: AppColors.accent)),
                    dashArray: [5, 4],
                  ),
                  LineChartBarData(
                    spots: spotsCarbs,
                    isCurved: true,
                    color: const Color(0xFFF97316),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: const Color(0xFFF97316))),
                    dashArray: [5, 4],
                  ),
                  LineChartBarData(
                    spots: spotsProteins,
                    isCurved: true,
                    color: AppColors.healthPrimary,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: AppColors.healthPrimary)),
                    dashArray: [5, 4],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              _legend(context, AppColors.accent, 'Calorías'),
              _legend(context, const Color(0xFFF97316), 'Carbohidratos (g)'),
              _legend(context, AppColors.healthPrimary, 'Proteínas (g)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toggle(BuildContext context, String label, bool is7) {
    final selected = _is7Days == is7;
    return GestureDetector(
      onTap: () => setState(() => _is7Days = is7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.border : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Widget _legend(BuildContext context, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
