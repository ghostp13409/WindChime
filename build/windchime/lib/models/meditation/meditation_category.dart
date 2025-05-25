import 'package:flutter/material.dart';
import 'package:windchime/models/meditation/meditation.dart';

class MeditationCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<Meditation> meditations;

  MeditationCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.meditations,
  });
}
