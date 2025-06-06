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
import 'package:windchime/services/utils/sound_utils.dart';

class GuidedTutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const GuidedTutorialScreen({
    super.key,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<GuidedTutorialScreen> createState() => _GuidedTutorialScreenState();
}

class _GuidedTutorialScreenState extends State<GuidedTutorialScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _startPulseDemo();
    });
  }

  void _startPulseDemo() {
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Header
            Text(
              'Guided Meditation',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.5,
                    fontSize: 32,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              'Experience mindfulness with expert narration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Meditation animation
            SizedBox(
              height: 200,
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFF6815B).withOpacity(0.6),
                              const Color(0xFFF6815B).withOpacity(0.2),
                              const Color(0xFFF6815B).withOpacity(0.05),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF6815B).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.headset,
                          size: 48,
                          color: const Color(0xFFF6815B),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Instructions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'What to expect:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF6815B),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionStep(
                    '1.',
                    'Choose your practice',
                    'Browse categories like Body Scan, Breathing, or Imagery',
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep(
                    '2.',
                    'Find your comfortable position',
                    'Sit or lie down in a quiet, comfortable space',
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep(
                    '3.',
                    'Follow the gentle guidance',
                    'Let the narrator guide you through the practice',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Categories preview
            Text(
              'Available practices:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
            ),

            const SizedBox(height: 20),

            // Category features
            _buildFeatureItem(
              icon: Icons.air,
              title: 'Breathing Practices',
              description: 'Mindful breathing exercises for focus and calm',
              color: const Color(0xFF7B65E4),
            ),

            const SizedBox(height: 16),

            _buildFeatureItem(
              icon: Icons.self_improvement,
              title: 'Brief Mindfulness',
              description: 'Quick 3-5 minute sessions for busy schedules',
              color: const Color(0xFFF6815B),
            ),

            const SizedBox(height: 16),

            _buildFeatureItem(
              icon: Icons.accessibility_new,
              title: 'Body Scan',
              description: 'Progressive relaxation and body awareness',
              color: const Color(0xFFFA6E5A),
            ),

            const SizedBox(height: 16),

            _buildFeatureItem(
              icon: Icons.event_seat,
              title: 'Sitting Meditations',
              description: 'Traditional mindfulness and wisdom practices',
              color: const Color(0xFFFFCF86),
            ),

            const SizedBox(height: 16),

            _buildFeatureItem(
              icon: Icons.landscape,
              title: 'Guided Imagery',
              description: 'Visualization techniques for deeper states',
              color: const Color(0xFF4CAF50),
            ),

            const SizedBox(height: 48),

            // Complete button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7B65E4),
                    const Color(0xFF7B65E4).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B65E4).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  playSound('sounds/startup/completetask.mp3');
                  widget.onComplete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Start Exploring',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.explore,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(
      String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFF6815B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.withOpacity(0.8),
                      height: 1.3,
                      letterSpacing: 0.1,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.withOpacity(0.8),
                      height: 1.3,
                      letterSpacing: 0.1,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
