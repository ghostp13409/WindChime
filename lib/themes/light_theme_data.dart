/*
 * Copyright (C) 2025 Parth Gajjar
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';

ThemeData lightThemeData = ThemeData(
  fontFamily: 'Montserrat',
  brightness: Brightness.light,
  primaryColor: const Color(0xFF80CBC4),
  scaffoldBackgroundColor: const Color(0xFFFAFAFA),
  cardColor: const Color(0xFFFFFFFF),
  dividerColor: const Color(0xFFE0E0E0),
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFFAFAFA),
    primary: Color(0xFF80CBC4),
    onSurface: Color(0xFF212121),
    onBackground: Color(0xFF212121),
    secondary: Color(0xFF26A69A),
    tertiary: Color(0xFF4DB6AC),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF424242),
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
    headlineLarge: TextStyle(
      color: Color(0xFF212121),
      fontWeight: FontWeight.w300,
      fontSize: 32,
    ),
    headlineSmall: TextStyle(
      color: Color(0xFF212121),
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
    titleLarge: TextStyle(
      color: Color(0xFF212121),
      fontWeight: FontWeight.w600,
      fontSize: 22,
    ),
    titleMedium: TextStyle(
      color: Color(0xFF212121),
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
    titleSmall: TextStyle(
      color: Color(0xFF212121),
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
    bodyLarge: TextStyle(
      color: Color(0xFF424242),
      fontWeight: FontWeight.w400,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: Color(0xFF424242),
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      color: Color(0xFF616161),
      fontWeight: FontWeight.w400,
      fontSize: 12,
    ),
  ),
);
