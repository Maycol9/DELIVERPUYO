import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.colorPrimary,
      brightness: Brightness.light,
      primary: AppColors.colorPrimary,
      onPrimary: AppColors.colorOnPrimary,
      surface: AppColors.colorSurface,
      onSurface: AppColors.colorTextPrimary,
      error: AppColors.colorError,
      onError: AppColors.colorOnPrimary,
    );

    const textTheme = TextTheme(
      displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.colorBackground,
      useMaterial3: true,
      textTheme: textTheme.apply(
        bodyColor: AppColors.colorTextPrimary,
        displayColor: AppColors.colorTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.colorPrimary,
        foregroundColor: AppColors.colorOnPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.colorSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.standard.radiusField),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppTokens.standard.radiusButton,
            ),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.colorSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.standard.radiusCard),
          side: const BorderSide(color: AppColors.colorOutline),
        ),
      ),
      extensions: const [AppTokens.standard],
    );
  }
}
