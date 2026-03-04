import 'package:flutter/material.dart';
import 'package:equilibra_mobile/data/models/registered_sleep_time_model.dart';
import 'package:equilibra_mobile/presentation/screens/sueno/widgets/sleep_period_card.dart';

class SleepPeriodsList extends StatelessWidget {
  const SleepPeriodsList({
    super.key,
    required this.periods,
    this.onOptionsTap,
  });

  final List<RegisteredSleepTimeModel> periods;
  final void Function(RegisteredSleepTimeModel period)? onOptionsTap;

  @override
  Widget build(BuildContext context) {
    if (periods.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Text(
          'No hay períodos de sueño registrados para este día.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      children: periods
          .map((p) => SleepPeriodCard(
                period: p,
                onOptionsTap: onOptionsTap != null ? () => onOptionsTap!(p) : null,
              ))
          .toList(),
    );
  }
}
