import 'package:flutter/material.dart';

/// Colores y gradientes de la app Equilibra.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52E0);
  static const Color accent = Color(0xFF4A90E2);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color hint = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color link = Color(0xFF4A90E2);

  /// Salud Tracker / Dashboard
  static const Color healthPrimary = Color(0xFF22C55E);
  static const Color healthPrimaryLight = Color(0xFFDCFCE7);

  /// Sueño
  static const Color sleepPrimary = Color(0xFF8B5CF6);
  static const Color sleepSecondary = Color(0xFFA78BFA);
  static const LinearGradient sleepGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sleepPrimary, sleepSecondary],
  );
}
