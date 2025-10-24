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
import 'package:windchime/services/changelog_service.dart';
import 'package:windchime/widgets/shared/changelog_dialog.dart';
import 'package:windchime/widgets/home/streak_card_widget.dart';
import 'package:windchime/widgets/home/mood_tracker_widget.dart';
import 'package:windchime/widgets/home/journey_carousel_widget.dart';
import 'package:windchime/widgets/home/quick_session_fab.dart';

class RedesignedHomeScreen extends StatefulWidget {
  const RedesignedHomeScreen({super.key});

  @override
  State<RedesignedHomeScreen> createState() => _RedesignedHomeScreenState();
}

class _RedesignedHomeScreenState extends State<RedesignedHomeScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Meditation data (same as original)
  static const Map<String, BreathingPattern> breathingPatterns = {
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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      playSound('sounds/startup/completetask.mp3');
      _fadeController.forward();
      _checkAndShowChangelog();
    });
  }

  Future<void> _checkAndShowChangelog() async {
    final shouldShow = await ChangelogService.shouldShowChangelog();
    if (shouldShow && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ChangelogDialog(),
      ).then((_) {
        ChangelogService.markChangelogAsShown();
      });
    }
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

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 20, 24, 16),
      child: Row(
        children: [
          // App Logo
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/welcome');
            },
            child: Container(
              width: 70,
              height: 70,
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
          const SizedBox(width: 8),

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

          // About Button
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
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
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
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: _currentPage == 0
                      ? Theme.of(context).colorScheme.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
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
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.air,
                  size: 20,
                  color: _currentPage == 0
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.6),
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
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: _currentPage == 1
                      ? Theme.of(context).colorScheme.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
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
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.headset,
                  size: 20,
                  color: _currentPage == 1
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreathworkSlivers() {
    return [
      // Header with description and history button
      SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.air,
                    size: 20,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Breathwork',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                        width: 1,
                      ),
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
                        color:
                            Theme.of(context).iconTheme.color?.withOpacity(0.7),
                      ),
                      iconSize: 18,
                      padding: const EdgeInsets.all(6),
                      constraints:
                          const BoxConstraints(minWidth: 30, minHeight: 30),
                      tooltip: 'History',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Conscious breathing techniques to reduce stress, improve focus, and enhance emotional well-being through guided patterns.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.withOpacity(0.8),
                      height: 1.3,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),

      // Grid layout
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final entry = breathingPatterns.entries.elementAt(index);
              final key = entry.key;
              final pattern = entry.value;

              return _buildMeditationCard(key, pattern);
            },
            childCount: breathingPatterns.length,
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ];
  }

  Widget _buildMeditationCard(String key, BreathingPattern pattern) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _startMeditation(key, _getDisplayTitle(key));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.light
                        ? [
                            pattern.primaryColor.withOpacity(0.35),
                            pattern.primaryColor.withOpacity(0.25),
                          ]
                        : [
                            pattern.primaryColor.withOpacity(0.08),
                            pattern.primaryColor.withOpacity(0.04),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Sound icon (placeholder)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.volume_up_outlined,
                    size: 16,
                    color: pattern.primaryColor,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              Theme.of(context).brightness == Brightness.light
                                  ? [
                                      pattern.primaryColor.withOpacity(0.35),
                                      pattern.primaryColor.withOpacity(0.25),
                                    ]
                                  : [
                                      pattern.primaryColor.withOpacity(0.2),
                                      pattern.primaryColor.withOpacity(0.1),
                                    ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getIconForPattern(key),
                        size: 24,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : pattern.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDisplayTitle(key),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                    height: 1.1,
                                    fontSize: 15,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pattern.name,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: pattern.primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getShortDescription(key),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade700,
                                    height: 1.3,
                                    fontSize: 10,
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
  }

  List<Widget> _buildGuidedMeditationSlivers() {
    final meditationCategories = [
      {
        'id': 'breathing_practices',
        'title': 'Breathing Practices',
        'icon': Icons.air,
        'color': const Color(0xFF6B46C1),
        'description':
            'Mindful breathing exercises for present moment awareness',
      },
      {
        'id': 'brief_mindfulness',
        'title': 'Brief Mindfulness',
        'icon': Icons.self_improvement,
        'color': const Color(0xFFEA580C),
        'description': 'Quick sessions for daily resets and mental clarity',
      },
      {
        'id': 'body_scan',
        'title': 'Body Scan',
        'icon': Icons.accessibility_new,
        'color': const Color(0xFFDC2626),
        'description': 'Body journey to release tension and build awareness',
      },
      {
        'id': 'sitting_meditations',
        'title': 'Sitting Meditations',
        'icon': Icons.event_seat,
        'color': const Color(0xFFF59E0B),
        'description':
            'Seated practices for breath, sound, and thought awareness',
      },
      {
        'id': 'guided_imagery',
        'title': 'Guided Imagery',
        'icon': Icons.landscape,
        'color': const Color(0xFF7C3AED),
        'description': 'Visualization for calm, resilience, and balance',
      },
      {
        'id': 'self_guided',
        'title': 'Self Guided',
        'icon': Icons.notifications_none,
        'color': const Color(0xFF059669),
        'description': 'Silent practice with bells for deeper concentration',
      },
    ];

    return [
      SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.headset,
                    size: 20,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Guided Meditations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                        width: 1,
                      ),
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
                        color:
                            Theme.of(context).iconTheme.color?.withOpacity(0.7),
                      ),
                      iconSize: 18,
                      padding: const EdgeInsets.all(6),
                      constraints:
                          const BoxConstraints(minWidth: 30, minHeight: 30),
                      tooltip: 'History',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Expert-guided meditation experiences with soothing narration and mindful awareness practices.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.withOpacity(0.8),
                      height: 1.3,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
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
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? [
                                      color.withOpacity(0.35),
                                      color.withOpacity(0.25),
                                    ]
                                  : [
                                      color.withOpacity(0.08),
                                      color.withOpacity(0.04),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? color.withOpacity(0.3)
                                  : color.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? [
                                            color.withOpacity(0.35),
                                            color.withOpacity(0.25),
                                          ]
                                        : [
                                            color.withOpacity(0.2),
                                            color.withOpacity(0.1),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  category['icon'] as IconData,
                                  size: 24,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : color,
                                ),
                              ),
                              const Spacer(),
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
                                          fontSize: 15,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    category['description'] as String,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey.shade700,
                                          height: 1.3,
                                          fontSize: 10,
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
            childCount: meditationCategories.length,
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ];
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              Column(
                children: [
                  // Fixed Header
                  _buildModernHeader(),

                  // New Feature Cards (Scrollable with content)
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Streak Card
                        const SliverToBoxAdapter(
                          child: StreakCardWidget(),
                        ),

                        // Mood Tracker
                        const SliverToBoxAdapter(
                          child: MoodTrackerWidget(),
                        ),

                        // Journey Carousel
                        const SliverToBoxAdapter(
                          child: JourneyCarouselWidget(),
                        ),

                        // Section Tabs
                        SliverToBoxAdapter(
                          child: _buildSectionTabs(),
                        ),

                        // Page View Content
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 700, // Adjust based on content
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              children: [
                                // Breathwork page
                                CustomScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  slivers: _buildBreathworkSlivers(),
                                ),
                                // Guided meditation page
                                CustomScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  slivers: _buildGuidedMeditationSlivers(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Quick Session FAB
              const Positioned(
                bottom: 16,
                right: 16,
                child: QuickSessionFAB(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
