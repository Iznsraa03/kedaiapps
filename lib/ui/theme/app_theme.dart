import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette — Blue & White
  static const Color primary = Color(0xFF1565C0); // Deep blue
  static const Color primaryLight = Color(0xFF1E88E5); // Medium blue
  static const Color primaryDark = Color(0xFF0D47A1); // Dark navy
  static const Color accent = Color(0xFF42A5F5); // Sky blue
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color background = Color(0xFFF0F4FF); // Light blue-white
  static const Color onPrimary = Color(0xFFFFFFFF); // White on blue
  static const Color onSurface = Color(0xFF1A237E); // Navy text
  static const Color subtle = Color(0xFF90A4AE); // Muted grey-blue
  static const Color error = Color(0xFFD32F2F); // Red error

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      surface: surface,
    ),
    scaffoldBackgroundColor: background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarThemeData(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        elevation: 3,
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.blue.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.blue.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: TextStyle(color: Colors.blue.shade700),
      prefixIconColor: primaryLight,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryDark,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primaryDark,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: onSurface, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, color: subtle),
    ),
  );
}
