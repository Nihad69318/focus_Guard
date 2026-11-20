import 'package:flutter/material.dart';

import '../color/app_colors.dart';

ThemeData _buildTheme(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;

  final Color background =
  isDark ? AppColors.darkBackground : AppColors.lightBackground;
  final Color surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
  final Color text = isDark ? AppColors.darkText : AppColors.lightText;
  final Color border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

  final ColorScheme scheme = ColorScheme(
    brightness: brightness,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: surface,
    onSurface: text,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    dividerColor: border,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondaryText,
    ),
  );
}

final ThemeData lightTheme = _buildTheme(Brightness.light);
final ThemeData darkTheme = _buildTheme(Brightness.dark);