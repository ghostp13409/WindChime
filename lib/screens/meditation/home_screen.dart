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
import 'package:windchime/screens/meditation/breathwork_history_screen.dart';

class MeditationHomeScreen extends StatefulWidget {
  const MeditationHomeScreen({super.key});

  @override
  State<MeditationHomeScreen> createState() => _MeditationHomeScreenState();
}

class _MeditationHomeScreenState extends State<MeditationHomeScreen> {
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
            subtitle: '4:6 breathing for deep rest',
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
            subtitle: 'Box breathing (4-4-4-4)',
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
            subtitle: 'Stanford 2:1 exhale technique',
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
            subtitle: 'Balanced 3:3 energizing breath',
            duration: '10 min',
            image: _happiness,
          ),
        ],
      ),
    ];

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Meditation',
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
                                    const BreathworkHistoryScreen(),
                              ),
                            );
                          },
                          onLongPress: () {
                            // Removed demo/test logic
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
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                child: Text(
                  'How are you feeling today?',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio:
                      0.85, // Slightly taller for better fit on small screens
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = _categories[index];
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _startMeditation(
                            category.meditations.first, category.name);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient:
                              Theme.of(context).brightness == Brightness.dark
                                  ? null
                                  : LinearGradient(
                                      colors: [
                                        category.color,
                                        category.color.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? category.color.withOpacity(0.2)
                              : null,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: category.color,
                            width:
                                Theme.of(context).brightness == Brightness.light
                                    ? 1
                                    : 2,
                          ),
                          boxShadow:
                              Theme.of(context).brightness == Brightness.light
                                  ? [
                                      BoxShadow(
                                        color: category.color.withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: Offset(0, 6),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      )
                                    : null,
                                child: Icon(
                                  category.icon,
                                  size: 32,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? category.color
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12), // Reduced spacing
                              Text(
                                category.name,
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  shadows: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6), // Reduced spacing
                              Text(
                                category.meditations.first.subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  shadows: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            offset: Offset(0, 1),
                                            blurRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _categories.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
