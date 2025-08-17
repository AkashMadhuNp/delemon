import 'package:delemon/core/colors/color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true, 
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      background: AppColors.lightBackground,
      onPrimary: Colors.white,
      onBackground: AppColors.lightText,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightText),
      bodyMedium: TextStyle(color: AppColors.lightSubText),
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      background: AppColors.darkBackground,
      onPrimary: Colors.white,
      onBackground: AppColors.darkText,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkSubText),
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
    ),
  );
}
