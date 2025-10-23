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
import 'package:flutter/services.dart';
import 'package:windchime/models/meditation/breathing_pattern.dart';
import 'package:windchime/models/meditation/meditation.dart';
import 'package:windchime/models/meditation/meditation_category.dart';
import 'package:windchime/screens/meditation/session_history_screen.dart';

class MeditationItems extends StatefulWidget {
  const MeditationItems({super.key});

  @override
  State<MeditationItems> createState() => _MeditationItemsState();
}

class _MeditationItemsState extends State<MeditationItems> {
  bool _showDemo = false;

  // Temp Image URLs
  static const String _sleep = 'images/meditation/sleep.png';
  static const String _focus = 'images/meditation/focus.png';
  static const String _anxiety = 'images/meditation/anxiety.png';
  static const String _happiness = 'images/meditation/happiness.png';

  static const Map<String, BreathingPattern> breathingPatterns = {
    'demo': BreathingPattern(
      name: 'Quick Demo',
      breatheInDuration: 2,
      holdInDuration: 1,
      breatheOutDuration: 2,
      holdOutDuration: 1,
      description: 'Quick 10-second demo session',
      primaryColor: Color(0xFF059669),
      audioPath: 'sounds/meditation/Focus.mp3',
    ),
    'default': BreathingPattern(
      name: '4-7-8 Technique',
      breatheInDuration: 4,
      holdInDuration: 7,
      breatheOutDuration: 8,
      holdOutDuration: 0,
      description: 'Dr. Weil\'s proven technique for stress relief',
      primaryColor: Color(0xFF6B46C1),
      audioPath: 'sounds/meditation/Sleep.mp3',
    ),
    'sleep': BreathingPattern(
      name: 'Sleep Induction',
      breatheInDuration: 4,
      holdInDuration: 0,
      breatheOutDuration: 6,
      holdOutDuration: 0,
      description: '4-6 breathing activates parasympathetic nervous system',
      primaryColor: Color(0xFF6B46C1),
      audioPath: 'sounds/meditation/Sleep.mp3',
    ),
    'focus': BreathingPattern(
      name: 'Box Breathing',
      breatheInDuration: 4,
      holdInDuration: 4,
      breatheOutDuration: 4,
      holdOutDuration: 4,
      description: 'Navy SEAL technique for cognitive performance',
      primaryColor: Color(0xFFEA580C),
      audioPath: 'sounds/meditation/Focus.mp3',
    ),
    'anxiety': BreathingPattern(
      name: 'Physiological Sigh',
      breatheInDuration: 4,
      holdInDuration: 0,
      breatheOutDuration: 8,
      holdOutDuration: 0,
      description: 'Stanford-researched 2:1 exhale-to-inhale ratio',
      primaryColor: Color(0xFF059669),
      audioPath: 'sounds/meditation/Anxiety.mp3',
    ),
    'happiness': BreathingPattern(
      name: 'Energizing Breath',
      breatheInDuration: 3,
      holdInDuration: 0,
      breatheOutDuration: 3,
      holdOutDuration: 0,
      description: 'Balanced 1:1 ratio for alertness and positive mood',
      primaryColor: Color(0xFFF59E0B),
      audioPath: 'sounds/meditation/happy.mp3',
    ),
  };

  List<MeditationCategory> get _categories {
    final baseCategories = [
      MeditationCategory(
        name: 'Sleep',
        icon: Icons.nightlight_round,
        color: const Color(0xFF6B46C1),
        meditations: [
          Meditation(
            title: 'Sleep Mode',
            subtitle: 'Relax and unwind',
            duration: '15 min',
            image: _sleep,
          ),
        ],
      ),
      MeditationCategory(
        name: 'Focus',
        icon: Icons.psychology,
        color: const Color(0xFFEA580C),
        meditations: [
          Meditation(
            title: 'Focus Mode',
            subtitle: 'Enhance concentration',
            duration: '10 min',
            image: _focus,
          ),
        ],
      ),
      MeditationCategory(
        name: 'Anxiety',
        icon: Icons.healing,
        color: const Color(0xFF059669),
        meditations: [
          Meditation(
            title: 'Anxiety Mode',
            subtitle: 'Find calmness',
            duration: '10 min',
            image: _anxiety,
          ),
        ],
      ),
      MeditationCategory(
        name: 'Happiness',
        icon: Icons.self_improvement,
        color: const Color(0xFFF59E0B),
        meditations: [
          Meditation(
            title: 'Happiness Mode',
            subtitle: 'Boost your mood',
            duration: '10 min',
            image: _happiness,
          ),
        ],
      ),
    ];

    if (_showDemo) {
      return [
        MeditationCategory(
          name: 'Demo',
          icon: Icons.play_circle_outline,
          color: const Color(0xFF059669),
          meditations: [
            Meditation(
              title: 'Quick Demo',
              subtitle: 'Try a 10-second session',
              duration: '10 sec',
              image: _focus,
            ),
          ],
        ),
        ...baseCategories,
      ];
    }

    return baseCategories;
  }

  void _startMeditation(Meditation meditation, String categoryName) {
    BreathingPattern pattern = breathingPatterns[categoryName.toLowerCase()] ??
        breathingPatterns['default']!;

    Navigator.pushNamed(
      context,
      '/meditation/instructions',
      arguments: {
        'breathingPattern': pattern,
        'meditation': meditation,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Meditate for...',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SessionHistoryScreen(),
                            ),
                          );
                        },
                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _showDemo = !_showDemo;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _showDemo
                                    ? 'Demo mode enabled'
                                    : 'Demo mode disabled',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: const Color(0xFF00C896),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(Icons.history),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            //FIXME: Removed How are you feeling today? text because of the padding issues
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            //   child: Text(
            //     'How are you feeling today?',
            //     style: Theme.of(context).textTheme.displayMedium,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 25,
                  crossAxisSpacing: 25,
                  childAspectRatio: 0.85,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _startMeditation(
                          category.meditations.first, category.name);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? category.color.withOpacity(0.2)
                            : category.color.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: category.color,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black.withOpacity(0.15)
                                    : Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: category.color.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category.icon,
                            size: 48,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? category.color
                                    : Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            category.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.meditations.first.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
