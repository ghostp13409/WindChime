import 'package:flutter/material.dart';
import 'package:prog2435_final_project_app/models/meditation/meditation.dart';

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
