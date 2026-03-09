import 'package:flutter/material.dart';
import 'package:equilibra_mobile/data/models/registered_sleep_time_model.dart';
import 'package:equilibra_mobile/presentation/screens/sueno/widgets/sleep_period_card.dart';

class SleepPeriodsList extends StatelessWidget {
  const SleepPeriodsList({
    super.key,
    required this.periods,
    this.pendingSleepIds = const {},
    this.onOptionsTap,
    this.onSyncTap,
  });

  final List<RegisteredSleepTimeModel> periods;
  final Set<String> pendingSleepIds;
  final void Function(RegisteredSleepTimeModel period)? onOptionsTap;
  final void Function(String periodId)? onSyncTap;

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
          .map((p) {
            final isPendingSync = pendingSleepIds.contains(p.id);
            return SleepPeriodCard(
              period: p,
              isPendingSync: isPendingSync,
              onOptionsTap: onOptionsTap != null ? () => onOptionsTap!(p) : null,
              onSyncTap: isPendingSync && onSyncTap != null ? () => onSyncTap!(p.id) : null,
            );
          })
          .toList(),
    );
  }
}
