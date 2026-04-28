import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0D5C63);
  static const Color secondary = Color(0xFFF4B400);
  static const Color background = Color(0xFFF7F6F2);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 0.5,
        margin: EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}
