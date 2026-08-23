import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Primitive tokens
  static const green800 = Color(0xFF006C57);
  static const green700 = Color(0xFF0E7C66);
  static const green100 = Color(0xFFDDF4EE);
  static const blue700 = Color(0xFF2457A6);
  static const amber700 = Color(0xFF9A6500);
  static const red700 = Color(0xFFB3261E);
  static const white = Color(0xFFFFFFFF);
  static const gray50 = Color(0xFFF7FAF9);
  static const gray100 = Color(0xFFE8EFEC);
  static const gray500 = Color(0xFF82918C);
  static const gray600 = Color(0xFF52615D);
  static const gray900 = Color(0xFF17211F);

  // Semantic tokens
  static const colorPrimary = green800;
  static const colorOnPrimary = white;
  static const colorBackground = gray50;
  static const colorSurface = white;
  static const colorSurfaceVariant = green100;
  static const colorTextPrimary = gray900;
  static const colorTextSecondary = gray600;
  static const colorError = red700;
  static const colorSuccess = green800;
  static const colorWarning = amber700;
  static const colorInfo = blue700;
  static const colorOutline = gray500;
}
