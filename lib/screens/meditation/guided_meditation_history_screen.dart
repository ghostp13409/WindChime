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
import 'package:intl/intl.dart';
import 'package:windchime/data/repositories/meditation_repository.dart';
import 'package:windchime/models/meditation/session_history.dart';

class GuidedMeditationHistoryScreen extends StatefulWidget {
  const GuidedMeditationHistoryScreen({super.key});

  @override
  _GuidedMeditationHistoryScreenState createState() =>
      _GuidedMeditationHistoryScreenState();
}

class _GuidedMeditationHistoryScreenState
    extends State<GuidedMeditationHistoryScreen> {
  final _meditationRepository = MeditationRepository();
  List<SessionHistory> _sessions = [];
  int _totalSessions = 0;
  int _totalMinutes = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final sessions = await _meditationRepository.getGuidedMeditationSessions();
    final totalSessions =
        await _meditationRepository.getGuidedMeditationSessionsCount();
    final totalMinutes =
        await _meditationRepository.getGuidedMeditationTotalMinutes();

    setState(() {
      _sessions = sessions;
      _totalSessions = totalSessions;
      _totalMinutes = totalMinutes ~/ 60;
      _isLoading = false;
    });
  }

  Future<void> _deleteSession(SessionHistory session) async {
    HapticFeedback.lightImpact();

    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Delete Session',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          content: Text(
            'Are you sure you want to delete this guided meditation session?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.withOpacity(0.8),
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _meditationRepository.deleteSession(session.id!);
      _loadData();
    }
  }

  // Get meditation type info (icon and color) for guided meditations only
  Map<String, dynamic> _getMeditationTypeInfo(String? meditationType) {
    final typeKey = meditationType?.toLowerCase() ?? '';

    // Handle guided meditation types
    if (typeKey.startsWith('guided_')) {
      final guidedType =
          typeKey.replaceFirst('guided_', '').replaceAll('_partial', '');

      // Extract actual meditation name and convert to readable format
      final meditationName = _formatMeditationName(guidedType);
      final categoryInfo = _getCategoryInfo(guidedType);

      return {
        'icon': categoryInfo['icon'],
        'color': categoryInfo['color'],
        'name': meditationName,
        'category': categoryInfo['category']
      };
    }

    return {
      'icon': Icons.headset,
      'color': const Color(0xFF8E97FD),
      'name': 'Guided Meditation',
      'category': 'Guided Meditation'
    };
  }

  // Convert stored meditation type to readable name
  String _formatMeditationName(String typeKey) {
    // Handle special cases first
    final specialCases = {
      'breath,_sound_and_body': 'Breath, Sound and Body',
      'breath,_sounds,_body,_thoughts,_emotions':
          'Breath, Sounds, Body, Thoughts, Emotions',
      'forty-five_minute_body_scan': 'Forty-Five Minute Body Scan',
      'forty-five_minute_bells_(15_min_intervals)':
          'Forty-Five Minute Bells (15 min intervals)',
      'forty-five_minute_bells_(5_min_intervals)':
          'Forty-Five Minute Bells (5 min intervals)',
      'twenty_minute_bells_(5_min_intervals)':
          'Twenty Minute Bells (5 min intervals)',
      'twenty-five_minute_bells_(5_min_intervals)':
          'Twenty-Five Minute Bells (5 min intervals)',
      'thirty_minute_bells_(5_min_intervals)':
          'Thirty Minute Bells (5 min intervals)',
    };

    if (specialCases.containsKey(typeKey)) {
      return specialCases[typeKey]!;
    }

    // Convert underscores to spaces and capitalize each word
    return typeKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word)
        .join(' ');
  }

  // Get category-specific info (icon and color)
  Map<String, dynamic> _getCategoryInfo(String guidedType) {
    // Map specific meditation names to their categories
    final categoryMappings = {
      // Breathing Practices
      'three_minute_breathing': 'breathing',
      'five_minute_breathing': 'breathing',
      'six_minute_breath_awareness': 'breathing',
      'ten_minute_breathing': 'breathing',
      'ten_minute_mindfulness_of_breathing': 'breathing',

      // Brief Mindfulness
      'brief_mindfulness_practice': 'mindfulness',
      'the_breathing_space': 'mindfulness',
      'the_tension_release_meditation': 'mindfulness',
      'three_step_breathing_space': 'mindfulness',
      'three_minute_mindfulness_of_sounds': 'mindfulness',

      // Body Scan
      'four_minute_body_scan': 'body_scan',
      'fifteen_minute_body_scan': 'body_scan',
      'twenty_minute_body_scan': 'body_scan',
      'body_scan': 'body_scan',
      'forty-five_minute_body_scan': 'body_scan',

      // Sitting Meditations
      'seated_meditation': 'sitting',
      'sitting_meditation': 'sitting',
      'breath,_sound_and_body': 'sitting',
      'breath,_sounds,_body,_thoughts,_emotions': 'sitting',
      'ten_minute_wisdom_meditation': 'sitting',
      'compassionate_breath': 'sitting',

      // Guided Imagery
      'mountain_meditation': 'imagery',

      // Self Guided
      'five_minutes_just_bells': 'self_guided',
      'ten_minutes_just_bells': 'self_guided',
      'twenty_minutes_just_bells': 'self_guided',
      'twenty_minute_bells_(5_min_intervals)': 'self_guided',
      'twenty-five_minute_bells_(5_min_intervals)': 'self_guided',
      'thirty_minute_bells_(5_min_intervals)': 'self_guided',
      'forty-five_minute_bells_(15_min_intervals)': 'self_guided',
      'forty-five_minute_bells_(5_min_intervals)': 'self_guided',
    };

    final category = categoryMappings[guidedType] ?? 'general';

    switch (category) {
      case 'breathing':
        return {
          'icon': Icons.air,
          'color': const Color(0xFF7B65E4),
          'category': 'Breathing Practices'
        };
      case 'mindfulness':
        return {
          'icon': Icons.self_improvement,
          'color': const Color(0xFFF6815B),
          'category': 'Brief Mindfulness'
        };
      case 'body_scan':
        return {
          'icon': Icons.accessibility_new,
          'color': const Color(0xFFFA6E5A),
          'category': 'Body Scan'
        };
      case 'sitting':
        return {
          'icon': Icons.event_seat,
          'color': const Color(0xFFFFCF86),
          'category': 'Sitting Meditation'
        };
      case 'imagery':
        return {
          'icon': Icons.landscape,
          'color': const Color(0xFF4CAF50),
          'category': 'Guided Imagery'
        };
      case 'self_guided':
        return {
          'icon': Icons.notifications_none,
          'color': const Color(0xFF9C27B0),
          'category': 'Self Guided'
        };
      default:
        return {
          'icon': Icons.headset,
          'color': const Color(0xFF8E97FD),
          'category': 'Guided Meditation'
        };
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${remainingSeconds}s';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) {
      return 'Today • ${DateFormat('h:mm a').format(date)}';
    } else if (sessionDate == yesterday) {
      return 'Yesterday • ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d • h:mm a').format(date);
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          // Back button
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
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.8),
              ),
              iconSize: 22,
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 16),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guided Meditation History',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
                Text(
                  'Your guided meditation journey',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.withOpacity(0.8),
                        letterSpacing: 0.2,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Total Sessions Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
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
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.2),
                          Theme.of(context).primaryColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.headset,
                      size: 24,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _totalSessions.toString(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Guided Sessions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Total Minutes Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
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
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.2),
                          Theme.of(context).primaryColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.access_time,
                      size: 24,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _totalMinutes.toString(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Minutes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SessionHistory session) {
    final typeInfo = _getMeditationTypeInfo(session.meditationType);
    final IconData icon = typeInfo['icon'];
    final Color color = typeInfo['color'];
    final String meditationName = typeInfo['name'];
    final String category = typeInfo['category'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
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
        borderRadius: BorderRadius.circular(20),
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
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon section
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
                      icon,
                      size: 28,
                      color: color,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Meditation name
                                  Text(
                                    meditationName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.3,
                                          fontSize: 15,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  // Category
                                  Text(
                                    category,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: color.withOpacity(0.8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatDuration(session.duration),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDate(session.date),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.withOpacity(0.8),
                                    letterSpacing: 0.1,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Delete button
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () => _deleteSession(session),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red.withOpacity(0.8),
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: 'Delete session',
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.headset,
                size: 40,
                color: Theme.of(context).primaryColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Guided Sessions Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start your first guided meditation\nto see your progress here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.withOpacity(0.7),
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildHeader(),

            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : _sessions.isEmpty
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),

                              // Stats Cards
                              _buildStatsCards(),

                              const SizedBox(height: 32),

                              // Sessions Header
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  children: [
                                    Text(
                                      'Recent Sessions',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.3,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${_sessions.length}',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Session List
                              ...(_sessions
                                  .map((session) => _buildSessionCard(session))
                                  .toList()),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
