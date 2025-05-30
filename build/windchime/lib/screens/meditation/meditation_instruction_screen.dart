import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windchime/models/meditation/breathing_pattern.dart';
import 'package:windchime/models/meditation/meditation.dart';
import 'package:windchime/screens/meditation/optimized_meditation_session_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
                            'About This Meditation',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Technique overview
                          _buildTechniqueOverview(),

                          const SizedBox(height: 24),

                          Text(
                            'Instructions',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 16),

                          _buildInstructionCard(
                            icon: Icons.air_rounded,
                            title: 'Breathing Pattern',
                            description: widget.breathingPattern.description,
                            details: _getBreathingPatternDetails(),
                          ),

                          const SizedBox(height: 16),

                          _buildInstructionCard(
                            icon: Icons.self_improvement,
                            title: 'Find Your Position',
                            description: _getPositionInstructions(),
                            details: _getPositionDetails(),
                          ),

                          const SizedBox(height: 16),

                          _buildInstructionCard(
                            icon: Icons.volume_up_rounded,
                            title: 'Using the App',
                            description: _getAppUsageInstructions(),
                            details: 'Let the gentle tones guide your rhythm',
                          ),

                          const SizedBox(height: 16),

                          _buildInstructionCard(
                            icon: Icons.psychology_rounded,
                            title: 'Mindful Focus',
                            description: _getMindfulnessInstructions(),
                            details: _getMindfulnessDetails(),
                          ),

                          const SizedBox(height: 24),

                          // Research & Sources section
                          _buildResearchSection(),

                          const SizedBox(height: 24),

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

  Widget _buildTechniqueOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.breathingPattern.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getTechniqueTitle(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getTechniqueDescription(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getScientificBasis(),
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchSection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.science,
                color: widget.breathingPattern.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Research & Sources',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._buildResearchLinks(),
        ],
      ),
    );
  }

  List<Widget> _buildResearchLinks() {
    final links = _getResearchLinks();
    return links
        .map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _launchURL(link['url']!),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          widget.breathingPattern.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.link,
                        color: widget.breathingPattern.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              link['title']!,
                              style: TextStyle(
                                fontSize: 13,
                                color: widget.breathingPattern.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (link['authors'] != null)
                              Text(
                                link['authors']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        color: Colors.white.withOpacity(0.5),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ))
        .toList();
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.open_in_new, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text('Opening research article...'),
              ],
            ),
            backgroundColor: widget.breathingPattern.primaryColor,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      // Fallback to copying to clipboard on error
      try {
        await Clipboard.setData(ClipboardData(text: url));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.content_copy, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                      'Could not open browser. Link copied to clipboard.'),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (clipboardError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  List<Map<String, String>> _getResearchLinks() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
        return [
          {
            'title':
                'Self-regulation of breathing as a primary treatment for anxiety',
            'authors': 'Jerath, R., et al. (2015)',
            'url':
                'https://link.springer.com/article/10.1007/s10484-015-9279-8',
          },
          {
            'title': 'How breath-control can change your life',
            'authors': 'Zaccaro, A., et al. (2018)',
            'url':
                'https://www.frontiersin.org/articles/10.3389/fnhum.2018.00353/full',
          },
        ];
      case 'focus mode':
        return [
          {
            'title': 'Breath of life: the respiratory vagal stimulation model',
            'authors': 'Gerritsen, R. J., & Band, G. P. (2018)',
            'url':
                'https://www.frontiersin.org/articles/10.3389/fnhum.2018.00397/full',
          },
          {
            'title':
                'Brief mindfulness meditation improves attention in novices',
            'authors': 'Norris, C. J., et al. (2020)',
            'url':
                'https://www.frontiersin.org/articles/10.3389/fnhum.2020.00067/full',
          },
        ];
      case 'anxiety mode':
        return [
          {
            'title':
                'Brief structured respiration practices enhance mood and reduce physiological arousal',
            'authors': 'Balban, M. Y., et al. (2023)',
            'url': 'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9860365/',
          },
          {
            'title': 'Dr. Andrew Huberman\'s Breathing Protocols',
            'authors': 'Stanford Neuroscience Research',
            'url': 'https://hubermanlab.com/the-science-of-breathing/',
          },
        ];
      case 'happiness mode':
        return [
          {
            'title':
                'The physiological effects of slow breathing in the healthy human',
            'authors': 'Russo, M. A., et al. (2017)',
            'url': 'https://breathe.ersjournals.com/content/13/4/298',
          },
          {
            'title': 'How breath-control can change your life',
            'authors': 'Zaccaro, A., et al. (2018)',
            'url':
                'https://www.frontiersin.org/articles/10.3389/fnhum.2018.00353/full',
          },
        ];
      default:
        return [
          {
            'title': 'Dr. Andrew Weil\'s 4-7-8 Breathing Exercise',
            'authors': 'Dr. Andrew Weil, MD',
            'url':
                'https://www.drweil.com/health-wellness/body-mind-spirit/stress-anxiety/breathing-three-exercises/',
          },
          {
            'title': 'Spontaneous Healing Research',
            'authors': 'Weil, A. (2011)',
            'url':
                'https://www.drweil.com/health-wellness/body-mind-spirit/stress-anxiety/breathing-three-exercises/',
          },
        ];
    }
  }

  String _getTechniqueTitle() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
        return 'Sleep Induction Breathing (4-6 Pattern)';
      case 'focus mode':
        return 'Box Breathing (Navy SEAL Technique)';
      case 'anxiety mode':
        return 'Physiological Sigh (Stanford Research)';
      case 'happiness mode':
        return 'Energizing Breath (Balanced Rhythm)';
      default:
        return '4-7-8 Breathing Technique';
    }
  }

  String _getTechniqueDescription() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
        return 'This gentle breathing pattern with a longer exhale naturally activates your parasympathetic nervous system, signaling your body to enter a state of rest and relaxation. The 4-6 rhythm is specifically designed to be sustainable and calming.';
      case 'focus mode':
        return 'Used by Navy SEALs and elite performers, box breathing creates rhythmic neural entrainment that enhances cognitive performance. The equal intervals help regulate your nervous system and improve decision-making under pressure.';
      case 'anxiety mode':
        return 'Based on Stanford neuroscience research, this technique uses a 2:1 exhale-to-inhale ratio to maximally activate the parasympathetic nervous system. It\'s the most effective breathing pattern for rapid anxiety reduction.';
      case 'happiness mode':
        return 'This balanced 1:1 breathing pattern promotes optimal autonomic nervous system balance, maintaining alertness while preventing stress activation. It\'s designed to boost energy and positive mood states naturally.';
      default:
        return 'Dr. Andrew Weil\'s renowned technique combines ancient pranayama wisdom with modern science. The extended exhale activates your body\'s natural relaxation response.';
    }
  }

  String _getScientificBasis() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
        return 'Research shows that exhale-focused breathing patterns increase heart rate variability and activate the vagus nerve, promoting deeper, more restorative sleep.';
      case 'focus mode':
        return 'Studies demonstrate that rhythmic breathing improves cognitive control, working memory, and sustained attention by optimizing brainwave patterns.';
      case 'anxiety mode':
        return 'Neuroscience research confirms that double-length exhales trigger the fastest parasympathetic response, reducing cortisol and activating calming neurotransmitters.';
      case 'happiness mode':
        return 'Balanced breathing ratios optimize oxygen-carbon dioxide exchange and promote balanced autonomic function associated with positive emotional states.';
      default:
        return 'Clinical studies show this pattern effectively reduces anxiety, lowers blood pressure, and improves overall stress resilience.';
    }
  }

  String _getPositionInstructions() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
        return 'Lie down comfortably in bed or recline in a chair';
      case 'focus mode':
        return 'Sit upright with spine straight, feet flat on floor';
      case 'anxiety mode':
        return 'Find any comfortable position where you feel safe and supported';
      case 'happiness mode':
        return 'Sit comfortably with an open, upright posture';
      default:
        return 'Sit comfortably with your back straight or lie down';
    }
  }

  String _getPositionDetails() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
        return 'Allow your body to fully relax into the surface beneath you';
      case 'focus mode':
        return 'Maintain alertness while staying relaxed and centered';
      case 'anxiety mode':
        return 'Close your eyes or soften your gaze to feel more secure';
      case 'happiness mode':
        return 'Keep your chest open and shoulders relaxed';
      default:
        return 'Close your eyes or soften your gaze downward';
    }
  }

  String _getAppUsageInstructions() {
    return 'The app will provide visual breathing cues and ambient sounds to guide your practice. Follow the expanding and contracting circle on screen';
  }

  String _getMindfulnessInstructions() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
        return 'Let go of the day\'s thoughts and focus only on your breath';
      case 'focus mode':
        return 'Maintain sharp attention on the breathing rhythm and counting';
      case 'anxiety mode':
        return 'If anxious thoughts arise, gently return to the exhale phase';
      case 'happiness mode':
        return 'Notice the energizing effects of each balanced breath cycle';
      default:
        return 'If your mind wanders, gently return to your breath';
    }
  }

  String _getMindfulnessDetails() {
    switch (widget.meditation.title.toLowerCase()) {
      case 'sleep mode':
        return 'There\'s no need to be perfect - just let yourself drift';
      case 'focus mode':
        return 'Precision in timing helps train concentration skills';
      case 'anxiety mode':
        return 'Each breath is bringing you back to safety and calm';
      case 'happiness mode':
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
        return 'This session will help slow your heart rate, relax your muscles, and prepare your mind for restful sleep. You may feel a gentle drowsiness settling in as your nervous system shifts into rest mode.';
      case 'focus mode':
        return 'This practice will enhance your concentration, improve mental clarity, and help you feel more centered and alert for tasks ahead. You may notice improved ability to maintain attention.';
      case 'anxiety mode':
        return 'This breathing technique activates your parasympathetic nervous system, reducing stress hormones and creating a sense of calm and safety. Relief often comes within just a few breath cycles.';
      case 'happiness mode':
        return 'This energizing breath work will boost oxygen flow, release endorphins, and help elevate your mood and overall sense of well-being. You may feel naturally more positive and energized.';
      default:
        return 'This meditation will help you feel more relaxed, centered, and present in the moment. Regular practice builds long-term stress resilience.';
    }
  }
}
