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

enum BreathingState { breatheIn, holdIn, breatheOut, holdOut }

class BreathingPattern {
  final String name;
  final int breatheInDuration; // in seconds
  final int holdInDuration;
  final int breatheOutDuration;
  final int holdOutDuration;
  final String description;
  final Color primaryColor;
  final String audioPath;

  const BreathingPattern({
    required this.name,
    required this.breatheInDuration,
    required this.holdInDuration,
    required this.breatheOutDuration,
    required this.holdOutDuration,
    required this.description,
    required this.primaryColor,
    required this.audioPath,
  });

  // Convert seconds to timer ticks (100ms per tick)
  int get breatheInTicks => breatheInDuration * 10;
  int get holdInTicks => holdInDuration * 10;
  int get breatheOutTicks => breatheOutDuration * 10;
  int get holdOutTicks => holdOutDuration * 10;
}
