import 'package:flutter/material.dart';

ThemeData lightThemeData = ThemeData(
  fontFamily: 'Montserrat',
  brightness: Brightness.light,
  primaryColor: Color(0xFF26A69A),
  scaffoldBackgroundColor: Color(0xFFFDFDFD),
  cardColor: Color(0xFFFFFFFF),
  iconTheme: IconThemeData(
    color: Color(0xFF212121),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Color(0xFF212121),
      fontWeight: FontWeight.bold,
      fontSize: 28,
    ),
    displayMedium: TextStyle(
      color: Color(0xFF212121),
      fontWeight: FontWeight.w600,
      fontSize: 24,
    ),
    displaySmall: TextStyle(
      color: Color(0xFF212121),
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    bodyLarge: TextStyle(
      color: Color(0xFF212121),
      fontWeight: FontWeight.w400,
      fontSize: 16,
    ),
  ),
);
