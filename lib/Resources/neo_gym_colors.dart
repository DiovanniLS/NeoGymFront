import 'package:flutter/material.dart';

class NeoGymColors {
  // Principal (Laranja)
  static const Color primary = Color(0xFFFF6B00);
  static const Color primaryDark = Color(0xFFE65100);
  static const Color primaryLight = Color(0xFFFFA040);

  // Fundo
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;

  // Texto
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textLight = Colors.white;

  // Bordas
  static const Color border = Color(0xFFE5E5E5);

  // Status
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB300);

  // Água (combina com fitness)
  static const Color water = Color(0xFF2196F3);
}

ThemeData neoGymTheme = ThemeData(
  primaryColor: NeoGymColors.primary,

  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: NeoGymColors.primary,
    onPrimary: Colors.white,
    secondary: NeoGymColors.primaryLight,
    onSecondary: Colors.white,
    error: NeoGymColors.error,
    onError: Colors.white,
    surface: NeoGymColors.surface,
    onSurface: NeoGymColors.textPrimary,
    background: NeoGymColors.background,
    onBackground: NeoGymColors.textPrimary,
  ),

  scaffoldBackgroundColor: NeoGymColors.background,

  appBarTheme: const AppBarTheme(
    backgroundColor: NeoGymColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: NeoGymColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: NeoGymColors.primary,
    foregroundColor: Colors.white,
  ),
);