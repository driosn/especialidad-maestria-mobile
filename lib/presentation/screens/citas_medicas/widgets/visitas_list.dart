import 'package:flutter/material.dart';
import 'package:equilibra_mobile/data/models/registered_medical_visit_model.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:equilibra_mobile/presentation/screens/citas_medicas/widgets/medical_visit_card.dart';

class VisitasList extends StatelessWidget {
  const VisitasList({
    super.key,
    required this.visits,
    this.pendingVisitIds = const {},
    this.onOptionsTap,
    this.onSyncTap,
  });

  final List<RegisteredMedicalVisitModel> visits;
  final Set<String> pendingVisitIds;
  final void Function(RegisteredMedicalVisitModel visit)? onOptionsTap;
  final void Function(String visitId)? onSyncTap;

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Text(
          'No hay visitas médicas registradas para este año.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      children: visits
          .map((v) {
            final isPendingSync = pendingVisitIds.contains(v.id);
            return MedicalVisitCard(
              visit: v,
              isPendingSync: isPendingSync,
              onOptionsTap: onOptionsTap != null ? () => onOptionsTap!(v) : null,
              onSyncTap: isPendingSync && onSyncTap != null ? () => onSyncTap!(v.id) : null,
            );
          })
          .toList(),
    );
  }
}
