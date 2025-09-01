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
import 'package:windchime/screens/meditation/meditation_session_screen.dart';
import 'package:windchime/screens/meditation/breathwork_info_screen.dart';

class MeditationInstructionScreen extends StatefulWidget {
  final BreathingPattern breathingPattern;
  final Meditation meditation;

  const MeditationInstructionScreen({
    super.key,
    required this.breathingPattern,
    required this.meditation,
  });

  @override
  State<MeditationInstructionScreen> createState() =>
      _MeditationInstructionScreenState();
}

class _MeditationInstructionScreenState
    extends State<MeditationInstructionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Duration selection
  int _selectedDuration =
      0; // Will be set in initState based on current duration
  final List<int> _availableDurations = [3, 5, 10, 15, 20]; // in minutes

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setDefaultDuration();
  }

  void _setDefaultDuration() {
    // Parse current duration and set as default
    final durationParts = widget.meditation.duration.split(' ');
    final durationValue = int.parse(durationParts[0]);

    // Set the current duration as selected, or closest available
    if (_availableDurations.contains(durationValue)) {
      _selectedDuration = durationValue;
    } else {
      // Find closest available duration
      _selectedDuration = _availableDurations.reduce((a, b) =>
          (a - durationValue).abs() < (b - durationValue).abs() ? a : b);
    }
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutCubic,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _startMeditation() {
    HapticFeedback.lightImpact();

    // Create new meditation object with selected duration
    final updatedMeditation = Meditation(
      title: widget.meditation.title,
      subtitle: widget.meditation.subtitle,
      duration: '$_selectedDuration min',
      image: widget.meditation.image,
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OptimizedMeditationSessionScreen(
          breathingPattern: widget.breathingPattern,
          meditation: updatedMeditation,
          onClose: () => Navigator.of(context).pop(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _navigateToInfoScreen() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BreathworkInfoScreen(
          breathingPattern: widget.breathingPattern,
          meditation: widget.meditation,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _showDurationSettings() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1C2031).withOpacity(0.95),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: widget.breathingPattern.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Session Duration',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose your meditation duration',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableDurations.map((duration) {
                  final isSelected = duration == _selectedDuration;
                  final isRecommended = duration.toString() ==
                      widget.meditation.duration.split(' ')[0];

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setDialogState(() {
                        _selectedDuration = duration;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.breathingPattern.primaryColor
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? widget.breathingPattern.primaryColor
                              : isRecommended
                                  ? widget.breathingPattern.primaryColor
                                      .withOpacity(0.6)
                                  : Colors.white.withOpacity(0.3),
                          width: isRecommended ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$duration min',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : widget.breathingPattern.primaryColor
                                        .withOpacity(0.8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Recommended',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {}); // Update the main widget's state
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.breathingPattern.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.light
                ? [
                    widget.breathingPattern.primaryColor.withOpacity(0.15),
                    Colors.white,
                    Colors.white,
                  ]
                : [
                    widget.breathingPattern.primaryColor.withOpacity(0.3),
                    const Color(0xFF1A1B2E).withOpacity(0.8),
                    const Color(0xFF0F1419),
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Compact Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showDurationSettings,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.breathingPattern.primaryColor
                                    .withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.breathingPattern.primaryColor
                                      .withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.timer_outlined,
                                color: widget.breathingPattern.primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _navigateToInfoScreen,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.breathingPattern.primaryColor
                                    .withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.breathingPattern.primaryColor
                                      .withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.info_outline_rounded,
                                color: widget.breathingPattern.primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Compact Title Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Ready to begin?',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.breathingPattern.primaryColor
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: widget.breathingPattern.primaryColor
                                .withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getMeditationIcon(),
                              color: widget.breathingPattern.primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.meditation.title} • $_selectedDuration min',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        Text(
                          'About This Meditation',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Technique overview
                        _buildTechniqueOverview(),

                        const SizedBox(height: 16),

                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _buildInstructionCard(
                          icon: Icons.air_rounded,
                          title: 'Breathing Pattern',
                          description: widget.breathingPattern.description,
                          details: _getBreathingPatternDetails(),
                        ),

                        const SizedBox(height: 12),

                        _buildInstructionCard(
                          icon: Icons.self_improvement,
                          title: 'Find Your Position',
                          description: _getPositionInstructions(),
                          details: _getPositionDetails(),
                        ),

                        const SizedBox(height: 12),

                        _buildInstructionCard(
                          icon: Icons.visibility_rounded,
                          title: 'Visual Guidance',
                          description:
                              'Start by watching the breathing circle expand and contract while listening to the gentle audio cues. This helps you learn the rhythm naturally',
                          details:
                              'The visual and audio work together to guide your perfect timing',
                        ),

                        const SizedBox(height: 12),

                        _buildInstructionCard(
                          icon: Icons.self_improvement_rounded,
                          title: 'Mindful Transition',
                          description:
                              'Once you feel comfortable with the rhythm, set your phone aside and close your eyes. Let the audio cues become your meditation guide',
                          details:
                              'Trust the sounds to carry you deeper into peaceful breathing',
                        ),

                        const SizedBox(height: 12),

                        _buildInstructionCard(
                          icon: Icons.psychology_rounded,
                          title: 'Mindful Focus',
                          description: _getMindfulnessInstructions(),
                          details: _getMindfulnessDetails(),
                        ),

                        const SizedBox(height: 16),

                        // Benefits section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: widget.breathingPattern.primaryColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'What to Expect',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getBenefitsText(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black87
                                      : Colors.white.withOpacity(0.8),
                                  height: 1.4,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Compact Start button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startMeditation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.breathingPattern.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 22),
                          const SizedBox(width: 6),
                          Text(
                            'Begin Meditation',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard({
    required IconData icon,
    required String title,
    required String description,
    required String details,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.breathingPattern.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: widget.breathingPattern.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black87
                        : Colors.white.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black54
                        : Colors.white.withOpacity(0.6),
                    height: 1.2,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMeditationIcon() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
      case 'deep sleep':
        return Icons.nightlight_round;
      case 'focus mode':
      case 'sharp focus':
        return Icons.psychology;
      case 'anxiety mode':
      case 'calm mind':
        return Icons.healing;
      case 'happiness mode':
      case 'joy & energy':
        return Icons.self_improvement;
      default:
        return Icons.self_improvement;
    }
  }

  Widget _buildTechniqueOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.breathingPattern.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.breathingPattern.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getMeditationIcon(),
                color: widget.breathingPattern.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getTechniqueTitle(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getTechniqueDescription(),
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black87
                  : Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _getScientificBasis(),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black54
                  : Colors.white.withOpacity(0.7),
              height: 1.3,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getTechniqueTitle() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
      case 'deep sleep':
        return 'Sleep Induction Breathing (4-6 Pattern)';
      case 'focus mode':
      case 'sharp focus':
        return 'Box Breathing (Navy SEAL Technique)';
      case 'anxiety mode':
      case 'calm mind':
        return 'Physiological Sigh (Stanford Research)';
      case 'happiness mode':
      case 'joy & energy':
        return 'Energizing Breath (Balanced Rhythm)';
      default:
        return '4-7-8 Breathing Technique';
    }
  }

  String _getTechniqueDescription() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
      case 'deep sleep':
        return 'This gentle breathing pattern with a longer exhale naturally activates your parasympathetic nervous system, signaling your body to enter a state of rest and relaxation. The 4-6 rhythm is specifically designed to be sustainable and calming.';
      case 'focus mode':
      case 'sharp focus':
        return 'Used by Navy SEALs and elite performers, box breathing creates rhythmic neural entrainment that enhances cognitive performance. The equal intervals help regulate your nervous system and improve decision-making under pressure.';
      case 'anxiety mode':
      case 'calm mind':
        return 'Based on Stanford neuroscience research, this technique uses a 2:1 exhale-to-inhale ratio to maximally activate the parasympathetic nervous system. It\'s the most effective breathing pattern for rapid anxiety reduction.';
      case 'happiness mode':
      case 'joy & energy':
        return 'This balanced 1:1 breathing pattern promotes optimal autonomic nervous system balance, maintaining alertness while preventing stress activation. It\'s designed to boost energy and positive mood states naturally.';
      default:
        return 'Dr. Andrew Weil\'s renowned technique combines ancient pranayama wisdom with modern science. The extended exhale activates your body\'s natural relaxation response.';
    }
  }

  String _getScientificBasis() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
      case 'deep sleep':
        return 'Research shows that exhale-focused breathing patterns increase heart rate variability and activate the vagus nerve, promoting deeper, more restorative sleep.';
      case 'focus mode':
      case 'sharp focus':
        return 'Studies demonstrate that rhythmic breathing improves cognitive control, working memory, and sustained attention by optimizing brainwave patterns.';
      case 'anxiety mode':
      case 'calm mind':
        return 'Neuroscience research confirms that double-length exhales trigger the fastest parasympathetic response, reducing cortisol and activating calming neurotransmitters.';
      case 'happiness mode':
      case 'joy & energy':
        return 'Balanced breathing ratios optimize oxygen-carbon dioxide exchange and promote balanced autonomic function associated with positive emotional states.';
      default:
        return 'Clinical studies show this pattern effectively reduces anxiety, lowers blood pressure, and improves overall stress resilience.';
    }
  }

  String _getPositionInstructions() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
      case 'deep sleep':
        return 'Lie down comfortably in bed or recline in a chair';
      case 'focus mode':
      case 'sharp focus':
        return 'Sit upright with spine straight, feet flat on floor';
      case 'anxiety mode':
      case 'calm mind':
        return 'Find any comfortable position where you feel safe and supported';
      case 'happiness mode':
      case 'joy & energy':
        return 'Sit comfortably with an open, upright posture';
      default:
        return 'Sit comfortably with your back straight or lie down';
    }
  }

  String _getPositionDetails() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
      case 'deep sleep':
        return 'Allow your body to fully relax into the surface beneath you';
      case 'focus mode':
      case 'sharp focus':
        return 'Maintain alertness while staying relaxed and centered';
      case 'anxiety mode':
      case 'calm mind':
        return 'Close your eyes or soften your gaze to feel more secure';
      case 'happiness mode':
      case 'joy & energy':
        return 'Keep your chest open and shoulders relaxed';
      default:
        return 'Close your eyes or soften your gaze downward';
    }
  }

  String _getMindfulnessInstructions() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
      case 'deep sleep':
        return 'Let go of the day\'s thoughts and focus only on your breath';
      case 'focus mode':
      case 'sharp focus':
        return 'Maintain sharp attention on the breathing rhythm and counting';
      case 'anxiety mode':
      case 'calm mind':
        return 'If anxious thoughts arise, gently return to the exhale phase';
      case 'happiness mode':
      case 'joy & energy':
        return 'Notice the energizing effects of each balanced breath cycle';
      default:
        return 'If your mind wanders, gently return to your breath';
    }
  }

  String _getMindfulnessDetails() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
      case 'deep sleep':
        return 'There\'s no need to be perfect - just let yourself drift';
      case 'focus mode':
      case 'sharp focus':
        return 'Precision in timing helps train concentration skills';
      case 'anxiety mode':
      case 'calm mind':
        return 'Each breath is bringing you back to safety and calm';
      case 'happiness mode':
      case 'joy & energy':
        return 'Feel the natural uplift that comes with mindful breathing';
      default:
        return 'There\'s no perfect way - just be present';
    }
  }

  String _getBreathingPatternDetails() {
    final pattern = widget.breathingPattern;
    if (pattern.holdInDuration == 0 && pattern.holdOutDuration == 0) {
      return 'Breathe in for ${pattern.breatheInDuration}s, breathe out for ${pattern.breatheOutDuration}s';
    } else {
      return 'Breathe in for ${pattern.breatheInDuration}s, hold for ${pattern.holdInDuration}s, breathe out for ${pattern.breatheOutDuration}s, rest for ${pattern.holdOutDuration}s';
    }
  }

  String _getBenefitsText() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
      case 'deep sleep':
        return 'This session will help slow your heart rate, relax your muscles, and prepare your mind for restful sleep. You may feel a gentle drowsiness settling in as your nervous system shifts into rest mode.';
      case 'focus mode':
      case 'sharp focus':
        return 'This practice will enhance your concentration, improve mental clarity, and help you feel more centered and alert for tasks ahead. You may notice improved ability to maintain attention.';
      case 'anxiety mode':
      case 'calm mind':
        return 'This breathing technique activates your parasympathetic nervous system, reducing stress hormones and creating a sense of calm and safety. Relief often comes within just a few breath cycles.';
      case 'happiness mode':
      case 'joy & energy':
        return 'This energizing breath work will boost oxygen flow, release endorphins, and help elevate your mood and overall sense of well-being. You may feel naturally more positive and energized.';
      default:
        return 'This meditation will help you feel more relaxed, centered, and present in the moment. Regular practice builds long-term stress resilience.';
    }
  }
}
