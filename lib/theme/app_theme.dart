import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

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
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
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
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    useMaterial3: true,
  );
}