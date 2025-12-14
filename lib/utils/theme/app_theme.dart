import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,

      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      surface: AppColors.backgroundLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    fontFamily: 'Plus Jakarta Sans',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontFamily: 'Noto Sans', fontSize: 16),
      bodyMedium: TextStyle(fontFamily: 'Noto Sans', fontSize: 14),
    ),
    chipTheme: ChipThemeData(
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey[200],
      labelStyle: const TextStyle(fontFamily: 'Noto Sans'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,

      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      surface: AppColors.backgroundDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    fontFamily: 'Plus Jakarta Sans',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontFamily: 'Noto Sans', fontSize: 16),
      bodyMedium: TextStyle(fontFamily: 'Noto Sans', fontSize: 14),
    ),
    chipTheme: ChipThemeData(
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey[800],
      labelStyle: const TextStyle(fontFamily: 'Noto Sans'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E2A30),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[800]!), // Apply side via shape if needed
      ),
    ),
  );
}
