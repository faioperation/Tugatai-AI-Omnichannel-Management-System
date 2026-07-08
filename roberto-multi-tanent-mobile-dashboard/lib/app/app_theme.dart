import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColor.primary,
      scaffoldBackgroundColor: AppColor.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColor.primary,
        secondary: AppColor.secondary,
        surface: AppColor.surfaceLight,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: AppColor.primary,
        onSurface: AppColor.textPrimaryLight,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColor.textPrimaryLight,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: AppColor.textPrimaryLight),
        bodyMedium: TextStyle(color: AppColor.textSecondaryLight),
      ),
      dividerTheme: const DividerThemeData(color: AppColor.borderLight, thickness: 1),
      cardTheme: CardThemeData(
        color: AppColor.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColor.borderLight),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.surfaceLight,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.textPrimaryLight),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColor.primary,
      scaffoldBackgroundColor: AppColor.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColor.primary,
        secondary: Color(0xff4B1B1D), // Darker shade of secondary
        surface: AppColor.surfaceDark,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColor.textPrimaryDark,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColor.textPrimaryDark,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: AppColor.textPrimaryDark),
        bodyMedium: TextStyle(color: AppColor.textSecondaryDark),
      ),
      dividerTheme: const DividerThemeData(color: AppColor.borderDark, thickness: 1),
      cardTheme: CardThemeData(
        color: AppColor.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColor.borderDark),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.surfaceDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.textPrimaryDark),
      ),
    );
  }
}
