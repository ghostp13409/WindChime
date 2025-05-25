import 'package:flutter/material.dart';

ThemeData darkThemeData = ThemeData(
  fontFamily: 'Montserrat',
  brightness: Brightness.dark,
  primaryColor: Color(0xFF3E2AD1),
  scaffoldBackgroundColor: Color(0xFF121421),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 28,
    ),
    displayMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 24,
    ),
    displaySmall: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    bodyLarge: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w400,
      fontSize: 16,
    ),
  ),
);
