import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:windchime/data/repositories/meditation_repository.dart';
import 'package:windchime/models/meditation/breathing_pattern.dart';
import 'package:windchime/models/meditation/meditation.dart';
import 'package:windchime/models/meditation/session_history.dart';

class MeditationSessionScreen extends StatefulWidget {
  final BreathingPattern breathingPattern;
  final Meditation meditation;
  final VoidCallback onClose;

  const MeditationSessionScreen({
    super.key,
    required this.breathingPattern,
    required this.meditation,
    required this.onClose,
  });

  @override
  State<MeditationSessionScreen> createState() =>
      _MeditationSessionScreenState();
}

class _MeditationSessionScreenState extends State<MeditationSessionScreen>
    with TickerProviderStateMixin {
  final _meditationRepository = MeditationRepository();

  // Animation Controllers
  late AnimationController _breathingController;
  late AnimationController _particleController;
  late AnimationController _waveController;
  late AnimationController _progressController;
  late AnimationController _fadeController;

  // Animations
  late Animation<double> _breathingAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  // Session state - using ValueNotifiers for reactive UI updates
  final ValueNotifier<int> _secondsNotifier = ValueNotifier(0);
  final ValueNotifier<int> _cycleNotifier = ValueNotifier(0);
  final ValueNotifier<BreathingState> _breathStateNotifier = ValueNotifier(BreathingState.breatheIn);
  final ValueNotifier<String> _instructionNotifier = ValueNotifier('Breathe In');
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);

  // Session variables
  int _seconds = 0;
  late Timer _timer;
  late AudioPlayer _audioPlayer;
  BreathingState _currentBreathState = BreathingState.breatheIn;
  String _breathingInstruction = 'Breathe In';
  int _currentCycle = 0;
  double _sessionProgress = 0.0;

  // Visual state
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();
  // Using RepaintBoundary and change notifier together for more efficient repainting
  final ValueNotifier<bool> _particleUpdateNotifier = ValueNotifier(false);

  // For triggering rebuilds only when needed
  final ValueNotifier<bool> _visualUpdateNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupParticles();
    _setupAudio();
    _startMeditation();
  }

  void _setupAnimations() {
    // Main breathing animation
    _breathingController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (widget.breathingPattern.breatheInDuration +
                     widget.breathingPattern.holdInDuration +
                     widget.breathingPattern.breatheOutDuration +
                     widget.breathingPattern.holdOutDuration) * 1000
      ),
    );

    _breathingAnimation = CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOutSine,
    );

    // Particle animation - using higher vsync frequency for smoother animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    // Add listener to update particles directly from animation frame
    _particleController.addListener(_updateParticlesFromAnimation);
    _particleController.repeat();

    _particleAnimation = _particleController;

    // Wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _waveAnimation = _waveController;

    // Progress animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    // Fade animation for transitions
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutCubic,
    );

    _breathingController.repeat();
    _fadeController.forward();
  }

  void _updateParticlesFromAnimation() {
    // This will run at the animation frame rate (typically 60fps)
    for (var particle in _particles) {
      particle.y -= particle.speed;
      if (particle.y < -0.1) {
        particle.y = 1.1;
        particle.x = _random.nextDouble();
      }

      // Add gentle floating movement based on animation value
      particle.x += (math.sin(_particleController.value * 2 * math.pi + particle.y * 4) * 0.0001);
    }

    // Notify only once per frame, allowing Flutter to optimize the rendering
    _particleUpdateNotifier.value = !_particleUpdateNotifier.value;
  }

  void _setupParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.001 + _random.nextDouble() * 0.003,
        size: 2 + _random.nextDouble() * 4,
        opacity: 0.1 + _random.nextDouble() * 0.3,
      ));
    }
    _particleUpdateNotifier.value = !_particleUpdateNotifier.value;
  }

  Future<void> _setupAudio() async {
    _audioPlayer = AudioPlayer();
    try {
      await _audioPlayer.setAsset('assets/${widget.breathingPattern.audioPath}');
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.setVolume(0.6);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  void _startMeditation() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _seconds++;
      _secondsNotifier.value = _seconds;
      if (_seconds % 10 == 0) {
        _updateSessionProgress();
      }
      _updateBreathingState();
      // Particle updates are now handled by the animation controller
      _checkMeditationCompletion();
    });
  }

  void _updateSessionProgress() {
    int totalDurationInSeconds = int.parse(widget.meditation.duration.split(' ')[0]) * 60;
    _sessionProgress = (_seconds / 10) / totalDurationInSeconds;
    _progressNotifier.value = _sessionProgress;
    if (_sessionProgress <= 1.0) {
      _progressController.animateTo(_sessionProgress);
    }
  }

  void _updateBreathingState() {
    final totalCycleDuration = (widget.breathingPattern.breatheInDuration +
        widget.breathingPattern.holdInDuration +
        widget.breathingPattern.breatheOutDuration +
        widget.breathingPattern.holdOutDuration) * 10; // Convert to 100ms ticks

    final cyclePosition = _seconds % totalCycleDuration;
    final newCycle = _seconds ~/ totalCycleDuration;

    if (newCycle != _currentCycle) {
      _currentCycle = newCycle;
      _cycleNotifier.value = _currentCycle;
    }

    BreathingState newState;
    String newInstruction;

    if (cyclePosition < widget.breathingPattern.breatheInDuration * 10) {
      newState = BreathingState.breatheIn;
      newInstruction = 'Breathe In';
    } else if (cyclePosition < (widget.breathingPattern.breatheInDuration +
                              widget.breathingPattern.holdInDuration) * 10) {
      newState = BreathingState.holdIn;
      newInstruction = 'Hold';
    } else if (cyclePosition < (widget.breathingPattern.breatheInDuration +
                              widget.breathingPattern.holdInDuration +
                              widget.breathingPattern.breatheOutDuration) * 10) {
      newState = BreathingState.breatheOut;
      newInstruction = 'Breathe Out';
    } else {
      newState = BreathingState.holdOut;
      newInstruction = 'Rest';
    }

    if (newState != _currentBreathState) {
      _currentBreathState = newState;
      _breathingInstruction = newInstruction;
      _breathStateNotifier.value = _currentBreathState;
      _instructionNotifier.value = _breathingInstruction;
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  void _checkMeditationCompletion() {
    int durationInSeconds = int.parse(widget.meditation.duration.split(' ')[0]) * 60;
    if (_seconds >= durationInSeconds * 10) { // Convert to 100ms ticks
      _completeMeditation();
    }
  }

  Future<void> _completeMeditation() async {
    _timer.cancel();
    _audioPlayer.stop();

    final session = SessionHistory(
      date: DateTime.now(),
      duration: _seconds ~/ 10, // Convert back to seconds
    );
    await _meditationRepository.addSession(session);

    if (mounted) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2031).withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🧘‍♀️ Session Complete',
          style: TextStyle(color: Colors.white, fontSize: 24),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How are you feeling?',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<int>(
              valueListenable: _secondsNotifier,
              builder: (context, seconds, child) {
                return Text(
                  'Duration: ${_formatTime(seconds ~/ 10)}',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEmotionButton('😌', 'Calm', () => _closeSession()),
              _buildEmotionButton('😊', 'Happy', () => _closeSession()),
              _buildEmotionButton('✨', 'Renewed', () => _closeSession()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionButton(String emoji, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _closeSession() {
    Navigator.of(context).pop();
    widget.onClose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double _getBreathingProgress() {
    final totalCycleDuration = (widget.breathingPattern.breatheInDuration +
        widget.breathingPattern.holdInDuration +
        widget.breathingPattern.breatheOutDuration +
        widget.breathingPattern.holdOutDuration) * 10;

    final cyclePosition = _seconds % totalCycleDuration;

    switch (_currentBreathState) {
      case BreathingState.breatheIn:
        final progress = cyclePosition / (widget.breathingPattern.breatheInDuration * 10);
        return progress.clamp(0.0, 1.0);
      case BreathingState.holdIn:
        return 1.0;
      case BreathingState.breatheOut:
        final breathInHoldDuration = (widget.breathingPattern.breatheInDuration +
                                     widget.breathingPattern.holdInDuration) * 10;
        final progressInBreathOut = (cyclePosition - breathInHoldDuration) /
                                   (widget.breathingPattern.breatheOutDuration * 10);
        return (1.0 - progressInBreathOut).clamp(0.0, 1.0);
      case BreathingState.holdOut:
        return 0.0;
    }
  }

  Color _getBreathingStateColor() {
    switch (_currentBreathState) {
      case BreathingState.breatheIn:
        return const Color(0xFF8E97FD);
      case BreathingState.holdIn:
        return const Color(0xFFFFCF86);
      case BreathingState.breatheOut:
        return const Color(0xFFA1D1B0);
      case BreathingState.holdOut:
        return const Color(0xFFB197FC);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _breathingController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    _audioPlayer.dispose();

    // Dispose all ValueNotifiers to prevent memory leaks
    _secondsNotifier.dispose();
    _cycleNotifier.dispose();
    _breathStateNotifier.dispose();
    _instructionNotifier.dispose();
    _progressNotifier.dispose();
    _particleUpdateNotifier.dispose();
    _visualUpdateNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.breathingPattern.primaryColor.withOpacity(0.8),
              const Color(0xFF0F1419),
              const Color(0xFF1A1B2E),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ValueListenableBuilder<bool>(
              valueListenable: _particleUpdateNotifier,
              builder: (context, _, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: ParticlePainter(_particles, _getBreathingStateColor()),
                );
              },
            ),

            // Background waves
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: WavePainter(_waveAnimation.value, _getBreathingStateColor()),
                );
              },
            ),

            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _showExitDialog(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 24),
                          ),
                        ),
                        // Session progress indicator
                        ValueListenableBuilder<double>(
                          valueListenable: _progressNotifier,
                          builder: (context, progress, child) {
                            return Container(
                              width: 120,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: progress,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Session info
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: Column(
                                children: [
                                  Text(
                                    widget.meditation.title,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.breathingPattern.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.7),
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 60),

                        // Breathing instruction
                        ValueListenableBuilder<String>(
                          valueListenable: _instructionNotifier,
                          builder: (context, instruction, child) {
                            return AnimatedBuilder(
                              animation: _fadeAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Text(
                                    instruction,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // Main breathing visualization
                        AnimatedBuilder(
                          animation: Listenable.merge([_breathingAnimation, _waveAnimation]),
                          builder: (context, child) {
                            double progress = _getBreathingProgress();
                            double size = 180 + (progress * 80);

                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow rings
                                for (int i = 3; i >= 1; i--)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 800),
                                    width: size + (i * 30),
                                    height: size + (i * 30),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _getBreathingStateColor().withOpacity(0.1 / i),
                                        width: 2,
                                      ),
                                    ),
                                  ),

                                // Main breathing orb
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOutSine,
                                  width: size,
                                  height: size,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        _getBreathingStateColor().withOpacity(0.8),
                                        _getBreathingStateColor().withOpacity(0.4),
                                        _getBreathingStateColor().withOpacity(0.1),
                                      ],
                                      stops: const [0.0, 0.7, 1.0],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getBreathingStateColor().withOpacity(0.4),
                                        blurRadius: 30,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                // Centered Text Widgets (Timer and Cycle)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ValueListenableBuilder<int>(
                                      valueListenable: _secondsNotifier,
                                      builder: (context, seconds, child) {
                                        return Text(
                                          _formatTime(seconds ~/ 10),
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w300,
                                            color: Colors.white,
                                            letterSpacing: 2.0,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    ValueListenableBuilder<int>(
                                      valueListenable: _cycleNotifier,
                                      builder: (context, cycle, child) {
                                        return Text(
                                          'Cycle $cycle',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.8),
                                            letterSpacing: 1.0,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 60),

                        // Breathing guide text
                        ValueListenableBuilder<BreathingState>(
                          valueListenable: _breathStateNotifier,
                          builder: (context, breathState, child) {
                            return AnimatedBuilder(
                              animation: _fadeAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _fadeAnimation.value * 0.7,
                                  child: Text(
                                    _getBreathingGuideText(breathState),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.6),
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            );
                          },
                        ),
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

  String _getBreathingGuideText(BreathingState breathState) {
    switch (breathState) {
      case BreathingState.breatheIn:
        return 'Fill your lungs slowly and deeply';
      case BreathingState.holdIn:
        return 'Hold gently, feel the stillness';
      case BreathingState.breatheOut:
        return 'Release slowly, let tension go';
      case BreathingState.holdOut:
        return 'Rest in the empty space';
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2031).withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'End Session?',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Your progress will be saved',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue', style: TextStyle(color: Colors.white70)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  _timer.cancel();
                  _audioPlayer.stop();

                  final session = SessionHistory(
                    date: DateTime.now(),
                    duration: _seconds ~/ 10,
                  );
                  await _meditationRepository.addSession(session);
                  widget.onClose();
                },
                child: const Text('End Session', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  final double speed;
  final double size;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;

  ParticlePainter(this.particles, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint..color = color.withOpacity(particle.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  WavePainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final waveHeight = 30.0;
    final waveWidth = size.width;

    for (int i = 0; i < 3; i++) {
      path.reset();
      final y = size.height * 0.5 + (i * 60);

      for (double x = 0; x <= waveWidth; x += 5) {
        final waveY = y + math.sin((x / waveWidth * 2 * math.pi) + (animationValue * 2 * math.pi) + (i * 0.5)) * waveHeight;
        if (x == 0) {
          path.moveTo(x, waveY);
        } else {
          path.lineTo(x, waveY);
        }
      }

      canvas.drawPath(path, paint..color = color.withOpacity(0.05 + (i * 0.02)));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
