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
