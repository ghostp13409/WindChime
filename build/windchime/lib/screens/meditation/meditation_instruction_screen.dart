import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windchime/models/meditation/breathing_pattern.dart';
import 'package:windchime/models/meditation/meditation.dart';
import 'package:windchime/screens/meditation/optimized_meditation_session_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OptimizedMeditationSessionScreen(
          breathingPattern: widget.breathingPattern,
          meditation: widget.meditation,
          onClose: () => Navigator.of(context).pop(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
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
            colors: [
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Title and meditation info
                  Text(
                    'Ready to begin?',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          widget.breathingPattern.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
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
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.meditation.title} • ${widget.meditation.duration}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Instructions section
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meditation Instructions',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          _buildInstructionCard(
                            icon: Icons.air_rounded,
                            title: 'Breathing Pattern',
                            description: widget.breathingPattern.description,
                            details: _getBreathingPatternDetails(),
                          ),

                          const SizedBox(height: 20),

                          _buildInstructionCard(
                            icon: Icons.self_improvement,
                            title: 'Find Your Position',
                            description:
                                'Sit comfortably with your back straight or lie down',
                            details:
                                'Close your eyes or soften your gaze downward',
                          ),

                          const SizedBox(height: 20),

                          _buildInstructionCard(
                            icon: Icons.volume_up_rounded,
                            title: 'Audio Guidance',
                            description:
                                'Follow the breathing cues and ambient sounds',
                            details: 'Let the gentle tones guide your rhythm',
                          ),

                          const SizedBox(height: 20),

                          _buildInstructionCard(
                            icon: Icons.psychology_rounded,
                            title: 'Mindful Focus',
                            description:
                                'If your mind wanders, gently return to your breath',
                            details:
                                'There\'s no perfect way - just be present',
                          ),

                          const SizedBox(height: 40),

                          // Benefits section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
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
                                      color:
                                          widget.breathingPattern.primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'What to Expect',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _getBenefitsText(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                    height: 1.5,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Start button
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startMeditation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.breathingPattern.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Begin Meditation',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.breathingPattern.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: widget.breathingPattern.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.3,
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
        return Icons.nightlight_round;
      case 'focus mode':
        return Icons.psychology;
      case 'anxiety mode':
        return Icons.healing;
      case 'happiness mode':
        return Icons.self_improvement;
      default:
        return Icons.self_improvement;
    }
  }

  String _getBreathingPatternDetails() {
    final pattern = widget.breathingPattern;
    return 'Breathe in for ${pattern.breatheInDuration}s, hold for ${pattern.holdInDuration}s, breathe out for ${pattern.breatheOutDuration}s, rest for ${pattern.holdOutDuration}s';
  }

  String _getBenefitsText() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
        return 'This session will help slow your heart rate, relax your muscles, and prepare your mind for restful sleep. You may feel a gentle drowsiness settling in.';
      case 'focus mode':
        return 'This practice will enhance your concentration, improve mental clarity, and help you feel more centered and alert for tasks ahead.';
      case 'anxiety mode':
        return 'This breathing technique activates your parasympathetic nervous system, reducing stress hormones and creating a sense of calm and safety.';
      case 'happiness mode':
        return 'This energizing breath work will boost oxygen flow, release endorphins, and help elevate your mood and overall sense of well-being.';
      default:
        return 'This meditation will help you feel more relaxed, centered, and present in the moment.';
    }
  }
}
