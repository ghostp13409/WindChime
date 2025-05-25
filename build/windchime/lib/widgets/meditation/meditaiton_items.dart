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
                    'Meditate',
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
