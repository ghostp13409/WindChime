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
import 'package:windchime/screens/meditation/breathwork_history_screen.dart';
import 'package:windchime/screens/meditation/guided_meditation_history_screen.dart';
import 'package:windchime/screens/meditation/guided_meditation_category_screen.dart';
import 'package:windchime/services/utils/sound_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final bool _showWelcome = false;

  // Meditation data
  static const Map<String, BreathingPattern> breathingPatterns = {
    'sleep': BreathingPattern(
      name: 'Sleep Induction',
      breatheInDuration: 4,
      holdInDuration: 0,
      breatheOutDuration: 6,
      holdOutDuration: 0,
      description: '4-6 breathing activates parasympathetic nervous system',
      primaryColor: Color(0xFF7B65E4),
      audioPath: 'sounds/meditation/Sleep.mp3',
    ),
    'focus': BreathingPattern(
      name: 'Box Breathing',
      breatheInDuration: 4,
      holdInDuration: 4,
      breatheOutDuration: 4,
      holdOutDuration: 4,
      description: 'Navy SEAL technique for cognitive performance',
      primaryColor: Color(0xFFF6815B),
      audioPath: 'sounds/meditation/Focus.mp3',
    ),
    'anxiety': BreathingPattern(
      name: 'Physiological Sigh',
      breatheInDuration: 4,
      holdInDuration: 0,
      breatheOutDuration: 8,
      holdOutDuration: 0,
      description: 'Stanford-researched 2:1 exhale-to-inhale ratio',
      primaryColor: Color(0xFF4CAF50),
      audioPath: 'sounds/meditation/Anxiety.mp3',
    ),
    'happiness': BreathingPattern(
      name: 'Energizing Breath',
      breatheInDuration: 3,
      holdInDuration: 0,
      breatheOutDuration: 3,
      holdOutDuration: 0,
      description: 'Balanced 1:1 ratio for alertness and positive mood',
      primaryColor: Color(0xFFFFCF86),
      audioPath: 'sounds/meditation/happy.mp3',
    ),
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Play welcome chime sound when the home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      playSound('sounds/startup/completetask.mp3');
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startMeditation(String patternKey, String title) {
    BreathingPattern pattern = breathingPatterns[patternKey]!;

    Navigator.pushNamed(
      context,
      '/meditation/instructions',
      arguments: {
        'breathingPattern': pattern,
        'meditation': Meditation(
          title: title,
          subtitle: pattern.description,
          duration: '10 min',
          image: 'images/meditation/$patternKey.png',
        ),
      },
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          // App Logo with gradient background - clickable
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/welcome');
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // App Name and Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WindChime',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
                Text(
                  'Find your inner peace',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.withOpacity(0.8),
                        letterSpacing: 0.2,
                      ),
                ),
              ],
            ),
          ),

          // Modern About Button
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/about');
              },
              icon: Icon(
                Icons.info_outline,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.8),
              ),
              iconSize: 22,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: _currentPage == 0
                      ? Theme.of(context).colorScheme.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: _currentPage == 0
                      ? Border.all(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.2),
                          width: 1,
                        )
                      : null,
                  boxShadow: _currentPage == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.air,
                      size: 18,
                      color: _currentPage == 0
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Breathwork',
                      style: TextStyle(
                        color: _currentPage == 0
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withOpacity(0.6),
                        fontWeight: _currentPage == 0
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: _currentPage == 1
                      ? Theme.of(context).colorScheme.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: _currentPage == 1
                      ? Border.all(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.2),
                          width: 1,
                        )
                      : null,
                  boxShadow: _currentPage == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.headset,
                      size: 18,
                      color: _currentPage == 1
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Guided',
                      style: TextStyle(
                        color: _currentPage == 1
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withOpacity(0.6),
                        fontWeight: _currentPage == 1
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedMeditationPage() {
    // Define the 6 main meditation categories
    final meditationCategories = [
      {
        'id': 'breathing_practices',
        'title': 'Breathing Practices',
        'icon': Icons.air,
        'color': const Color(0xFF7B65E4),
        'description':
            'Cultivate present moment awareness through mindful breathing exercises that help center your mind and body',
      },
      {
        'id': 'brief_mindfulness',
        'title': 'Brief Mindfulness',
        'icon': Icons.self_improvement,
        'color': const Color(0xFFF6815B),
        'description':
            'Short powerful sessions for quick resets during your day, providing instant grounding and mental clarity',
      },
      {
        'id': 'body_scan',
        'title': 'Body Scan',
        'icon': Icons.accessibility_new,
        'color': const Color(0xFFFA6E5A),
        'description':
            'Systematic journey through your body to develop embodied awareness and release physical tension',
      },
      {
        'id': 'sitting_meditations',
        'title': 'Sitting Meditations',
        'icon': Icons.event_seat,
        'color': const Color(0xFFFFCF86),
        'description':
            'Traditional seated practices combining breath, sound, and thought awareness for deep inner stillness',
      },
      {
        'id': 'guided_imagery',
        'title': 'Guided Imagery',
        'icon': Icons.landscape,
        'color': const Color(0xFF4CAF50),
        'description':
            'Visualization techniques using imagination to foster calm, resilience, and emotional balance',
      },
      {
        'id': 'self_guided',
        'title': 'Self Guided',
        'icon': Icons.notifications_none,
        'color': const Color(0xFF9C27B0),
        'description':
            'Silent meditation with mindfulness bells to structure your personal practice and deepen concentration',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant header with history button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Guided Meditations',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: -0.5,
                                  fontSize: 32,
                                ),
                      ),
                    ),
                    // History button
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const GuidedMeditationHistoryScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.history,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withOpacity(0.8),
                        ),
                        iconSize: 22,
                        padding: const EdgeInsets.all(12),
                        tooltip: 'Guided Meditation History',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Expert-guided meditation experiences with soothing narration and mindful awareness practices.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Meditation categories grid
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: meditationCategories.length,
              itemBuilder: (context, index) {
                final category = meditationCategories[index];
                final color = category['color'] as Color;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _navigateToGuidedMeditationCategory(
                      category['id'] as String,
                      category['title'] as String,
                      category['description'] as String,
                      color,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          // Subtle gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  color.withOpacity(0.08),
                                  color.withOpacity(0.04),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon with elegant styling
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        color.withOpacity(0.2),
                                        color.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    category['icon'] as IconData,
                                    size: 28,
                                    color: color,
                                  ),
                                ),

                                const Spacer(),

                                // Text content
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category['title'] as String,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.2,
                                            height: 1.1,
                                            fontSize: 16,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category['description'] as String,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey.withOpacity(0.8),
                                            height: 1.3,
                                            letterSpacing: 0.0,
                                            fontSize: 11,
                                          ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToGuidedMeditationCategory(
      String categoryId, String title, String description, Color color) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuidedMeditationCategoryScreen(
          categoryId: categoryId,
          categoryTitle: title,
          categoryDescription: description,
          categoryColor: color,
        ),
      ),
    );
  }

  Widget _buildBreathworkPage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant header with history button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Breathwork',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: -0.5,
                                  fontSize: 32,
                                ),
                      ),
                    ),
                    // History button
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BreathworkHistoryScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.history,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withOpacity(0.8),
                        ),
                        iconSize: 22,
                        padding: const EdgeInsets.all(12),
                        tooltip: 'Session History',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Conscious breathing techniques to reduce stress, improve focus, and enhance emotional well-being through guided patterns.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Professional grid layout
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: breathingPatterns.length,
              itemBuilder: (context, index) {
                final entry = breathingPatterns.entries.elementAt(index);
                final key = entry.key;
                final pattern = entry.value;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _startMeditation(key, _getDisplayTitle(key));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          // Subtle gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  pattern.primaryColor.withOpacity(0.08),
                                  pattern.primaryColor.withOpacity(0.04),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon with elegant styling
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        pattern.primaryColor.withOpacity(0.2),
                                        pattern.primaryColor.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    _getIconForPattern(key),
                                    size: 28,
                                    color: pattern.primaryColor,
                                  ),
                                ),

                                const Spacer(),

                                // Text content
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getDisplayTitle(key),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.2,
                                            height: 1.1,
                                            fontSize: 16,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      pattern.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: pattern.primaryColor,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.0,
                                            fontSize: 12,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getShortDescription(key),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey.withOpacity(0.8),
                                            height: 1.3,
                                            letterSpacing: 0.0,
                                            fontSize: 11,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayTitle(String key) {
    switch (key) {
      case 'sleep':
        return 'Deep Sleep';
      case 'focus':
        return 'Sharp Focus';
      case 'anxiety':
        return 'Calm Mind';
      case 'happiness':
        return 'Joy & Energy';
      default:
        return 'Meditation';
    }
  }

  String _getShortDescription(String key) {
    switch (key) {
      case 'sleep':
        return '4:6 exhale-focused pattern activates sleep response';
      case 'focus':
        return 'Box breathing (4-4-4-4) used by Navy SEALs';
      case 'anxiety':
        return 'Stanford 2:1 exhale ratio for rapid anxiety relief';
      case 'happiness':
        return 'Balanced 3:3 pattern for positive energy & mood';
      default:
        return 'Guided breathing exercise';
    }
  }

  IconData _getIconForPattern(String key) {
    switch (key) {
      case 'sleep':
        return Icons.nightlight_round;
      case 'focus':
        return Icons.psychology;
      case 'anxiety':
        return Icons.healing;
      case 'happiness':
        return Icons.wb_sunny;
      default:
        return Icons.air;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Modern Header
                  _buildModernHeader(),

                  // Section Tabs
                  _buildSectionTabs(),

                  const SizedBox(height: 8),

                  // Swipeable Content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        _buildBreathworkPage(),
                        _buildGuidedMeditationPage(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
