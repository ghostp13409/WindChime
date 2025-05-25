import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prog2435_final_project_app/models/meditation/breathing_pattern.dart';
import 'package:prog2435_final_project_app/models/meditation/meditation.dart';
import 'package:prog2435_final_project_app/models/meditation/meditation_category.dart';
import 'package:prog2435_final_project_app/screens/meditation/session_history_screen.dart';

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
    'default': BreathingPattern(
      name: '4-7-8 Technique',
      breatheInDuration: 4,
      holdInDuration: 7,
      breatheOutDuration: 5,
      holdOutDuration: 3,
      description: 'Calming breath for relaxation',
      primaryColor: Color(0xFF8E97FD),
      audioPath: 'sounds/meditation/Sleep.mp3',
    ),
    'sleep': BreathingPattern(
      name: 'Deep Sleep',
      breatheInDuration: 4,
      holdInDuration: 4,
      breatheOutDuration: 8,
      holdOutDuration: 2,
      description: 'Longer exhales for better sleep',
      primaryColor: Color(0xFF7B65E4),
      audioPath: 'sounds/meditation/Sleep.mp3',
    ),
    'focus': BreathingPattern(
      name: 'Box Breathing',
      breatheInDuration: 4,
      holdInDuration: 4,
      breatheOutDuration: 4,
      holdOutDuration: 4,
      description: 'Equal timing for better focus',
      primaryColor: Color(0xFFF6815B),
      audioPath: 'sounds/meditation/Focus.mp3',
    ),
    'anxiety': BreathingPattern(
      name: 'Calming Breath',
      breatheInDuration: 5,
      holdInDuration: 5,
      breatheOutDuration: 5,
      holdOutDuration: 2,
      description: 'Longer exhales to reduce anxiety',
      primaryColor: Color(0xFFFA6E5A),
      audioPath: 'sounds/meditation/Anxiety.mp3',
    ),
    'happiness': BreathingPattern(
      name: 'Energy Breath',
      breatheInDuration: 2,
      holdInDuration: 1,
      breatheOutDuration: 2,
      holdOutDuration: 1,
      description: 'Quick rhythm for energy and joy',
      primaryColor: Color(0xFFFFCF86),
      audioPath: 'sounds/meditation/happy.mp3',
    ),
  };

  final List<MeditationCategory> _categories = [
    MeditationCategory(
      name: 'Sleep',
      icon: Icons.nightlight_round,
      color: const Color(0xFF8E97FD),
      meditations: [
        Meditation(
          title: 'Sleep Mode',
          subtitle: 'Relax and drift off',
          duration: '15 min',
          image: _sleep,
        ),
      ],
    ),
    MeditationCategory(
      name: 'Focus',
      icon: Icons.psychology,
      color: const Color(0xFFF6815B),
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
      color: const Color(0xFFFA6E5A),
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
      color: const Color(0xFFFFCF86),
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

  void _startMeditation(Meditation meditation, String categoryName) {
    BreathingPattern pattern = breathingPatterns[categoryName.toLowerCase()] ??
        breathingPatterns['default']!;

    Navigator.pushNamed(
      context,
      '/meditation/session',
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                        IconButton(
                          icon: const Icon(Icons.history),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SessionHistoryScreen(),
                              ),
                            );
                          },
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.85,
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? category.color.withOpacity(0.2)
                              : category.color.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: category.color,
                            width: 2,
                          ),
                          boxShadow:
                              Theme.of(context).brightness == Brightness.light
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category.icon,
                              size: 48,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
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
