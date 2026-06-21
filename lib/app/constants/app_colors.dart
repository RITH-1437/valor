import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors - Luxury Minimal
  static const Color primary = Color(0xFF111827);
  static const Color secondary = Color(0xFFD4AF37);
  static const Color accent = Color(0xFF6B7280);

  // Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FA);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textLightSecondary = Color.fromRGBO(255, 255, 255, 0.85);
  static const Color textLightTertiary = Color.fromRGBO(255, 255, 255, 0.65);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Border
  static const Color border = Color(0xFFE5E7EB);

  // Glass effect
  static const Color glassWhite = Color.fromRGBO(255, 255, 255, 0.75);
  static const Color glassWhiteStrong = Color.fromRGBO(255, 255, 255, 0.90);
  static const Color glassBorder = Color.fromRGBO(255, 255, 255, 0.50);
  static const Color glassBorderStrong = Color.fromRGBO(255, 255, 255, 0.80);
  static const Color glassDark = Color.fromRGBO(17, 24, 39, 0.10);
  static const Color primaryLight = Color(0xFF374151);

  static const List<Color> backgroundGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF8F9FA),
  ];

  static const List<Color> splashGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF3F4F6),
  ];

  // Shadows
  static List<BoxShadow> get glassShadow => const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      blurRadius: 20,
      offset: Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get lightGlow => const [
    BoxShadow(
      color: Color.fromRGBO(212, 175, 55, 0.15),
      blurRadius: 30,
      spreadRadius: 2,
    ),
  ];
}