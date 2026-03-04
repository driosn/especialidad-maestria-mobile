import 'package:flutter/material.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';

/// Caja con los requisitos de la contraseña.
class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({
    super.key,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasNumber,
  });

  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'La contraseña debe contener:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          _RequirementRow(met: hasMinLength, text: 'Al menos 8 caracteres'),
          _RequirementRow(met: hasUppercase, text: 'Una letra mayúscula'),
          _RequirementRow(met: hasNumber, text: 'Un número'),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.met, required this.text});

  final bool met;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: met ? Colors.green : AppColors.hint,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: met ? Colors.green : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
