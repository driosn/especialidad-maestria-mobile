import 'package:flutter/material.dart';
import 'package:equilibra_mobile/data/models/registered_medical_visit_model.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:equilibra_mobile/presentation/screens/citas_medicas/widgets/medical_visit_card.dart';

class VisitasList extends StatelessWidget {
  const VisitasList({
    super.key,
    required this.visits,
    this.onOptionsTap,
  });

  final List<RegisteredMedicalVisitModel> visits;
  final void Function(RegisteredMedicalVisitModel visit)? onOptionsTap;

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
          .map((v) => MedicalVisitCard(
                visit: v,
                onOptionsTap: onOptionsTap != null ? () => onOptionsTap!(v) : null,
              ))
          .toList(),
    );
  }
}
