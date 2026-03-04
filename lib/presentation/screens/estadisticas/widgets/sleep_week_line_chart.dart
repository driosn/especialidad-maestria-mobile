import 'package:equilibra_mobile/data/models/registered_sleep_time_model.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Gráfico de líneas: Horas de sueño por semana (L M M J V S D).
class SleepWeekLineChart extends StatelessWidget {
  const SleepWeekLineChart({super.key, required this.sleepPeriods});

  final List<RegisteredSleepTimeModel> sleepPeriods;

  static const _labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final byDate = <DateTime, int>{};
    for (final p in sleepPeriods) {
      final d = DateTime(p.startTimestamp.year, p.startTimestamp.month, p.startTimestamp.day);
      byDate[d] = (byDate[d] ?? 0) + p.durationMinutes;
    }
    DateTime monday = DateTime.now();
    if (byDate.isNotEmpty) {
      final minDate = byDate.keys.reduce((a, b) => a.isBefore(b) ? a : b);
      monday = minDate.subtract(Duration(days: minDate.weekday - 1));
    } else {
      monday = monday.subtract(Duration(days: monday.weekday - 1));
    }
    final hoursByDay = List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      final min = byDate[d] ?? 0;
      return min / 60.0;
    });
    final maxH = hoursByDay.fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = (maxH < 6 ? 10.0 : maxH + 2).clamp(6.0, 12.0);

    final spots = hoursByDay.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
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
          Text(
            'Horas de Sueño Diarias',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, meta) => Text(
                        v.toInt().toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i >= 0 && i < 7) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _labels[i],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
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
                maxX: 6,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.accent,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 5,
                        color: AppColors.accent,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Horas',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
