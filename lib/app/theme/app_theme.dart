import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color black = Color(0xFF111111);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gold = Color(0xFFD4AF37);
  static const Color gray = Color(0xFF6B7280);
  static const Color darkGray = Color(0xFF1F2937);

  // Light theme colors
  static const Color lightBg = Color(0xFFF8F8F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF111111);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);

  static ThemeData fashionTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    colorScheme: const ColorScheme.dark(
      primary: gold,
      secondary: white,
      surface: darkGray,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: black,
      foregroundColor: white,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: white, letterSpacing: -0.5),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: white, letterSpacing: -1.5),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: white, letterSpacing: -0.5),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: white, letterSpacing: -1),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: white),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: white),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: white),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: gray),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: gray),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: white, letterSpacing: 0.5),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkGray,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: gray),
      hintStyle: const TextStyle(fontSize: 14, color: gray),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: darkGray)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: darkGray)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: gold, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: black,
        minimumSize: const Size(double.infinity, 56),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: gray, textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: darkGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: darkGray)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  static ThemeData lightFashionTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    colorScheme: const ColorScheme.light(
      primary: gold,
      secondary: black,
      surface: lightSurface,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: lightBg,
      foregroundColor: lightText,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: lightText, letterSpacing: -0.5),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: lightText, letterSpacing: -1.5),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: lightText, letterSpacing: -0.5),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: lightText, letterSpacing: -1),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: lightText),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: lightText),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: lightText),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: lightTextSecondary),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: lightTextSecondary),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: lightText, letterSpacing: 0.5),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: lightTextSecondary),
      hintStyle: const TextStyle(fontSize: 14, color: lightTextSecondary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: lightBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: lightBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: gold, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: white,
        minimumSize: const Size(double.infinity, 56),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: gray, textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: lightBorder)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}
