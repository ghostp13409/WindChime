import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JourneyCarouselWidget extends StatefulWidget {
  const JourneyCarouselWidget({super.key});

  @override
  State<JourneyCarouselWidget> createState() => _JourneyCarouselWidgetState();
}

class _JourneyCarouselWidgetState extends State<JourneyCarouselWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  final List<Map<String, dynamic>> _journeys = [
    {
      'id': 'sleep_reset',
      'title': '7-Day Sleep Reset',
      'description': 'Master the art of deep, restful sleep',
      'currentDay': 3,
      'totalDays': 7,
      'color': const Color(0xFF6B46C1),
      'icon': Icons.nightlight_round,
      'isActive': true,
    },
    {
      'id': 'stress_relief',
      'title': 'Stress Relief Path',
      'description': 'Find calm in the chaos of daily life',
      'currentDay': 1,
      'totalDays': 14,
      'color': const Color(0xFF059669),
      'icon': Icons.spa,
      'isActive': true,
    },
    {
      'id': 'focus_mastery',
      'title': 'Focus Mastery',
      'description': 'Sharpen your mind and boost productivity',
      'currentDay': 0,
      'totalDays': 10,
      'color': const Color(0xFFEA580C),
      'icon': Icons.psychology,
      'isActive': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onJourneyTapped(Map<String, dynamic> journey) {
    HapticFeedback.lightImpact();
    final action = journey['isActive'] ? 'Continue' : 'Start';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action journey: ${journey['title']} 🎯'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Row(
            children: [
              Icon(
                Icons.auto_stories,
                size: 20,
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Your Journeys',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
              ),
            ],
          ),
        ),

        // Journey carousel
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _journeys.length,
            itemBuilder: (context, index) {
              return _buildJourneyCard(_journeys[index], index);
            },
          ),
        ),

        // Page indicators
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _journeys.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyCard(Map<String, dynamic> journey, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = journey['color'] as Color;
    final isActive = journey['isActive'] as bool;
    final currentDay = journey['currentDay'] as int;
    final totalDays = journey['totalDays'] as int;
    final progress = isActive ? currentDay / totalDays : 0.0;

    return GestureDetector(
      onTap: () => _onJourneyTapped(journey),
      child: AnimatedScale(
        scale: _currentPage == index ? 1.0 : 0.9,
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Gradient background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              color.withOpacity(0.25),
                              color.withOpacity(0.1),
                            ]
                          : [
                              color.withOpacity(0.4),
                              color.withOpacity(0.2),
                            ],
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon and title row
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color.withOpacity(isDark ? 0.3 : 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              journey['icon'] as IconData,
                              color: isDark ? color : Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  journey['title'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.3,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                if (isActive)
                                  Text(
                                    'Day $currentDay of $totalDays',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: color,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                  )
                                else
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.lock_outline,
                                        size: 12,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withOpacity(0.6),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Not started',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color
                                                  ?.withOpacity(0.6),
                                            ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Description
                      Text(
                        journey['description'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withOpacity(0.7),
                              height: 1.3,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // Progress or action button
                      if (isActive) ...[
                        // Progress dots
                        Row(
                          children: List.generate(totalDays, (i) {
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: i < currentDay ? 12 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: i < currentDay
                                    ? color
                                    : Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ] else ...[
                        // Start button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color, width: 1.5),
                          ),
                          child: Text(
                            'Start Journey',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Continue indicator for active journeys
                if (isActive)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continue',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
