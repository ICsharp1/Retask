import 'package:flutter/material.dart';

class AppThemes {
  static const double _borderRadius = 8.0;

  static final lightColorScheme = ColorScheme.light(
    primary: Colors.blue[600]!,
    onPrimary: Colors.white,
    secondary: Colors.cyan[500]!,
    onSecondary: Colors.white,
    surface: Colors.grey[50]!,
    onSurface: Colors.black87,
    background: Colors.white,
    onBackground: Colors.black87,
    error: Colors.red[700]!,
    onError: Colors.white,
  );

  static final darkColorScheme = ColorScheme.dark(
    primary: const Color(0xFF64B5F6), // Light Blue
    onPrimary: Colors.black87,
    secondary: const Color(0xFF4DD0E1), // Cyan
    onSecondary: Colors.black87,
    surface: Colors.black,
    onSurface: Colors.white,
    background: Colors.black,
    onBackground: Colors.white,
    error: const Color(0xFFCF6679),
    onError: Colors.black87,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.surface,
      foregroundColor: lightColorScheme.onSurface,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: lightColorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.surface,
      foregroundColor: darkColorScheme.onSurface,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF2C2C2C),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        side: const BorderSide(color: Color(0xFF404040)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkColorScheme.primary,
      foregroundColor: darkColorScheme.onPrimary,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: darkColorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
    ),
  );
}
