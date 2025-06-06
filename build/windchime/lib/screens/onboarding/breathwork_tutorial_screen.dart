import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windchime/services/utils/sound_utils.dart';

class BreathworkTutorialScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const BreathworkTutorialScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<BreathworkTutorialScreen> createState() =>
      _BreathworkTutorialScreenState();
}

class _BreathworkTutorialScreenState extends State<BreathworkTutorialScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _fadeController;
  late Animation<double> _breathAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _breathAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _startBreathingDemo();
    });
  }

  void _startBreathingDemo() {
    _breathController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
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
              'Breathwork Meditation',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.5,
                    fontSize: 32,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              'Learn the fundamentals of conscious breathing',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Breathing animation circle
            SizedBox(
              height: 200,
              child: Center(
                child: AnimatedBuilder(
                  animation: _breathAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _breathAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF7B65E4).withOpacity(0.6),
                              const Color(0xFF7B65E4).withOpacity(0.2),
                              const Color(0xFF7B65E4).withOpacity(0.05),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7B65E4).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.air,
                          size: 48,
                          color: const Color(0xFF7B65E4),
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
                    'How it works:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7B65E4),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionStep(
                    '1.',
                    'Choose a breathing pattern',
                    'Select from Focus, Sleep, Anxiety Relief, or Energy',
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep(
                    '2.',
                    'Follow the visual guide',
                    'Watch the circle expand and contract to time your breath',
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep(
                    '3.',
                    'Listen to the audio cues',
                    'Gentle sounds guide your inhale, hold, and exhale',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Features
            _buildFeatureItem(
              icon: Icons.psychology,
              title: 'Science-backed patterns',
              description: 'Box breathing, 4-7-8 technique, and more',
              color: const Color(0xFF7B65E4),
            ),

            const SizedBox(height: 20),

            _buildFeatureItem(
              icon: Icons.timer,
              title: 'Customizable sessions',
              description: 'Choose your duration from 3 to 20 minutes',
              color: const Color(0xFFF6815B),
            ),

            const SizedBox(height: 20),

            _buildFeatureItem(
              icon: Icons.volume_up,
              title: 'Audio guidance',
              description: 'Soothing sounds to enhance your practice',
              color: const Color(0xFF4CAF50),
            ),

            const SizedBox(height: 48),

            // Continue button
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
                  widget.onNext();
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
                      'Continue',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
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
            color: const Color(0xFF7B65E4),
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
