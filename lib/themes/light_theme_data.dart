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
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  cardColor: const Color(0xFFFFFFFF),
  iconTheme: const IconThemeData(
    color: Color(0xFF424242),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Color(0xFF424242),
      fontWeight: FontWeight.bold,
      fontSize: 28,
    ),
    displayMedium: TextStyle(
      color: Color(0xFF424242),
      fontWeight: FontWeight.w600,
      fontSize: 24,
    ),
    displaySmall: TextStyle(
      color: Color(0xFF424242),
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    bodyLarge: TextStyle(
      color: Color(0xFF424242),
      fontWeight: FontWeight.w400,
      fontSize: 16,
    ),
  ),
);
