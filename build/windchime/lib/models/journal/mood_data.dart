import 'package:flutter/material.dart';

class MoodData {
  final String emoji;
  final String label;
  final Color color;
  final Color darkColor;
  final IconData icon;

  const MoodData({
    required this.emoji,
    required this.label,
    required this.color,
    required this.darkColor,
    required this.icon,
  });
}

class Moods {
  static const happy = MoodData(
    emoji: '😊',
    label: 'Happy',
    color: Color(0xFFFFD93D),
    darkColor: Color(0xFFFFB800),
    icon: Icons.sentiment_very_satisfied,
  );

  static const calm = MoodData(
    emoji: '😌',
    label: 'Calm',
    color: Color(0xFF4ECCA3),
    darkColor: Color(0xFF45B68E),
    icon: Icons.spa,
  );

  static const sad = MoodData(
    emoji: '😔',
    label: 'Sad',
    color: Color(0xFF6C7BA1),
    darkColor: Color(0xFF4A5C8C),
    icon: Icons.sentiment_dissatisfied,
  );

  static const angry = MoodData(
    emoji: '😤',
    label: 'Angry',
    color: Color(0xFFFF6B6B),
    darkColor: Color(0xFFE74C3C),
    icon: Icons.mood_bad,
  );

  static const anxious = MoodData(
    emoji: '😟',
    label: 'Anxious',
    color: Color(0xFFA683E3),
    darkColor: Color(0xFF8E44AD),
    icon: Icons.psychology,
  );

  static List<MoodData> all = [happy, calm, sad, angry, anxious];

  static MoodData? fromEmoji(String? emoji) {
    if (emoji == null) return null;
    return all.firstWhere(
      (mood) => mood.emoji == emoji.split(' ')[0],
      orElse: () => happy,
    );
  }
}
