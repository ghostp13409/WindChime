// New class to define breathing patterns
// TODO: Make hold BreathOut Opstional (not all patterns have it)
// TODO: Customer Animations?
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
