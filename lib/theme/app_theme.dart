import 'package:flutter/material.dart';

class AppTheme {

static ThemeData lightTheme = ThemeData(
brightness: Brightness.light,
scaffoldBackgroundColor: const Color(0xFFF9FAFB),
primaryColor: const Color(0xFF4F46E5),

colorScheme: const ColorScheme.light(
primary: Color(0xFF4F46E5),
secondary: Color(0xFF0D9488),
),

appBarTheme: const AppBarTheme(
backgroundColor: Colors.transparent,
elevation: 0,
foregroundColor: Colors.black87,
),

cardColor: Colors.white,
);

static ThemeData darkTheme = ThemeData(
brightness: Brightness.dark,
scaffoldBackgroundColor: const Color(0xFF111827),
primaryColor: const Color(0xFF818CF8),

colorScheme: const ColorScheme.dark(
primary: Color(0xFF818CF8),
secondary: Color(0xFF2DD4BF),
),

appBarTheme: const AppBarTheme(
backgroundColor: Colors.transparent,
elevation: 0,
),

cardColor: const Color(0xFF1F2937),
);

}
