import 'package:flutter/material.dart';

class AppTheme {

static ThemeData lightTheme = ThemeData(
brightness: Brightness.light,
scaffoldBackgroundColor: Color(0xFFF3E9DC),
primaryColor: Color(0xFF5E3023),

colorScheme: const ColorScheme.light(
primary: Color(0xFF5E3023),
secondary: Color(0xFFC08552),
),

appBarTheme: const AppBarTheme(
backgroundColor: Colors.transparent,
elevation: 0,
foregroundColor: Color(0xFF3B2A23),
),

cardColor: Colors.white,
);

static ThemeData darkTheme = ThemeData(
brightness: Brightness.dark,
scaffoldBackgroundColor: Color(0xFF2B1A14),
primaryColor: Color(0xFFC08552),

colorScheme: const ColorScheme.dark(
primary: Color(0xFFC08552),
secondary: Color(0xFFC08552),
),

appBarTheme: const AppBarTheme(
backgroundColor: Colors.transparent,
elevation: 0,
),

cardColor: Color(0xFF3A231B),
);

}
