import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final light = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.onLightSecondary,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.lightBackground,
      onSurface: Colors.black,
    ),
    useMaterial3: true,
  );

  static final dark = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.onDarkSecondary,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.darkBackground,
      onSurface: Colors.white,
    ),
    useMaterial3: true,
  );
}