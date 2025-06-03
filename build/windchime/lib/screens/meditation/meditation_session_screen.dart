import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:windchime/data/repositories/meditation_repository.dart';
import 'package:windchime/models/meditation/breathing_pattern.dart';
import 'package:windchime/models/meditation/meditation.dart';
import 'package:windchime/models/meditation/session_history.dart';

class OptimizedMeditationSessionScreen extends StatefulWidget {
  final BreathingPattern breathingPattern;
  final Meditation meditation;
  final VoidCallback onClose;

  const OptimizedMeditationSessionScreen({
    super.key,
    required this.breathingPattern,
    required this.meditation,
    required this.onClose,
  });

  @override
  State<OptimizedMeditationSessionScreen> createState() =>
      _OptimizedMeditationSessionScreenState();
}

class _OptimizedMeditationSessionScreenState
    extends State<OptimizedMeditationSessionScreen>
    with TickerProviderStateMixin {
  final _meditationRepository = MeditationRepository();

  // Animation Controllers - reduced to essential ones
  late AnimationController _breathingController;
  late AnimationController _particleController;
  late AnimationController _progressController;
  late AnimationController _fadeController;

  // Animations
  late Animation<double> _breathingAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  // Session state - using ValueNotifiers for reactive UI updates
  final ValueNotifier<int> _secondsNotifier = ValueNotifier(0);
  final ValueNotifier<int> _cycleNotifier = ValueNotifier(0);
  final ValueNotifier<BreathingState> _breathStateNotifier =
      ValueNotifier(BreathingState.breatheIn);
  final ValueNotifier<String> _instructionNotifier =
      ValueNotifier('Breathe In');
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);
  final ValueNotifier<int> _stageRemainingTimeNotifier = ValueNotifier(0);

  // Session variables
  int _seconds = 0;
  late Timer _timer;
  late AudioPlayer _audioPlayer;
  late AudioPlayer _stateChangeAudioPlayer;
  BreathingState _currentBreathState = BreathingState.breatheIn;
  String _breathingInstruction = 'Breathe In';
  int _currentCycle = 0;
  double _sessionProgress = 0.0;
  int _stageRemainingTime = 0;

  // Optimized particle system
  late ParticleSystem _particleSystem;
  late Ticker _particleTicker;
  int _frameCount = 0;

  // Cached values for performance
  Color? _cachedBreathingColor;
  BreathingState? _lastBreathState;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupOptimizedParticleSystem();
    _setupAudio();
    _setupStateChangeAudio();
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
                  widget.breathingPattern.holdOutDuration) *
              1000),
    );

    _breathingAnimation = CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOutSine,
    );

    //TODO: WAVE_SPEED - Adjust duration to control background wave animation speed
    // Duration: 10 seconds = faster waves, 20 seconds = gentle waves, 60 seconds = very slow
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(
          seconds: 20), // Faster wave animation for visible movement
    );

    _particleAnimation = _particleController;

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
    _particleController.repeat(); // Make sure wave animation repeats
    _fadeController.forward();
  }

  void _setupOptimizedParticleSystem() {
    // Initialize with default values, will be updated when widget is built
    _particleSystem = ParticleSystem(
      particleCount: 20, // Increased count since we're optimizing performance
      screenWidth: 400, // Default width, will be updated
      screenHeight: 800, // Default height, will be updated
    );

    // Use a ticker for particle updates instead of animation controller listener
    _particleTicker = createTicker(_updateParticles);
    _particleTicker.start();
  }

  void _updateParticles(Duration elapsed) {
    _frameCount++;

    // Update particles at 60fps but only repaint every 2nd frame for better performance
    if (_frameCount % 1 == 0) {
      final deltaTime = elapsed.inMilliseconds / 1000.0;
      _particleSystem.update(deltaTime, _getBreathingStateColor());

      // Only trigger repaint if particles actually moved significantly
      if (_particleSystem.needsRepaint) {
        setState(() {}); // Minimal state update
      }
    }
  }

  Future<void> _setupAudio() async {
    _audioPlayer = AudioPlayer();
    try {
      //TODO: BACKGROUND_MUSIC_VOLUME - Adjust background music volume (0.0 to 1.0)
      // Lower values allow breathing cues to be heard more clearly
      await _audioPlayer.setVolume(0.1);
      await _audioPlayer
          .setAsset('assets/${widget.breathingPattern.audioPath}');
      await _audioPlayer.setLoopMode(LoopMode.one);

      // Start playing background music
      await _audioPlayer.play();

      debugPrint(
          'Background music started: ${widget.breathingPattern.audioPath}');
    } catch (e) {
      debugPrint('Error playing background audio: $e');
    }
  }

  void _setupStateChangeAudio() {
    _stateChangeAudioPlayer = AudioPlayer();
  }

  Future<void> _playStateChangeSound(BreathingState state) async {
    try {
      String soundPath;
      switch (state) {
        case BreathingState.breatheIn:
          soundPath = 'assets/sounds/meditation/statechange/breath_in.wav';
          break;
        case BreathingState.holdIn:
          soundPath = 'assets/sounds/meditation/statechange/hold.wav';
          break;
        case BreathingState.breatheOut:
          soundPath = 'assets/sounds/meditation/statechange/breath_out.wav';
          break;
        case BreathingState.holdOut:
          soundPath = 'assets/sounds/meditation/statechange/rest.wav';
          break;
      }

      // Stop any current cue sound to prevent overlapping
      if (_stateChangeAudioPlayer.playing) {
        await _stateChangeAudioPlayer.stop();
      }

      //TODO: BREATHING_CUE_VOLUME - Adjust breathing state change cue volume (0.0 to 1.0)
      // Higher values make the cues more prominent
      await _stateChangeAudioPlayer.setVolume(1.0);

      // Set the audio source and play immediately
      await _stateChangeAudioPlayer.setAsset(soundPath);
      await _stateChangeAudioPlayer.seek(Duration.zero);

      // Use fire-and-forget approach for better reliability
      _stateChangeAudioPlayer.play().catchError((error) {
        debugPrint('Error during audio playback: $error');
      });

      debugPrint('Playing state change sound: $soundPath for state: $state');
    } catch (e) {
      debugPrint('Error playing state change sound: $e');
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
      _checkMeditationCompletion();
    });
  }

  void _updateSessionProgress() {
    int totalDurationInSeconds;
    final durationParts = widget.meditation.duration.split(' ');
    final durationValue = int.parse(durationParts[0]);
    final durationUnit = durationParts[1].toLowerCase();

    if (durationUnit.startsWith('sec')) {
      totalDurationInSeconds = durationValue;
    } else {
      totalDurationInSeconds = durationValue * 60; // minutes to seconds
    }

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
            widget.breathingPattern.holdOutDuration) *
        10;

    final cyclePosition = _seconds % totalCycleDuration;
    final newCycle = _seconds ~/ totalCycleDuration;

    if (newCycle != _currentCycle) {
      _currentCycle = newCycle;
      _cycleNotifier.value = _currentCycle;
    }

    BreathingState newState;
    String newInstruction;
    int stageRemainingTime;

    if (cyclePosition < widget.breathingPattern.breatheInDuration * 10) {
      newState = BreathingState.breatheIn;
      newInstruction = 'Breathe In';
      stageRemainingTime =
          widget.breathingPattern.breatheInDuration - (cyclePosition ~/ 10);
    } else if (cyclePosition <
        (widget.breathingPattern.breatheInDuration +
                widget.breathingPattern.holdInDuration) *
            10) {
      newState = BreathingState.holdIn;
      newInstruction = 'Hold';
      final holdPosition =
          cyclePosition - (widget.breathingPattern.breatheInDuration * 10);
      stageRemainingTime =
          widget.breathingPattern.holdInDuration - (holdPosition ~/ 10);
    } else if (cyclePosition <
        (widget.breathingPattern.breatheInDuration +
                widget.breathingPattern.holdInDuration +
                widget.breathingPattern.breatheOutDuration) *
            10) {
      newState = BreathingState.breatheOut;
      newInstruction = 'Breathe Out';
      final breathOutPosition = cyclePosition -
          ((widget.breathingPattern.breatheInDuration +
                  widget.breathingPattern.holdInDuration) *
              10);
      stageRemainingTime = widget.breathingPattern.breatheOutDuration -
          (breathOutPosition ~/ 10);
    } else {
      newState = BreathingState.holdOut;
      newInstruction = 'Rest';
      final holdOutPosition = cyclePosition -
          ((widget.breathingPattern.breatheInDuration +
                  widget.breathingPattern.holdInDuration +
                  widget.breathingPattern.breatheOutDuration) *
              10);
      stageRemainingTime =
          widget.breathingPattern.holdOutDuration - (holdOutPosition ~/ 10);
    }

    // Update stage remaining time
    _stageRemainingTime = stageRemainingTime;
    _stageRemainingTimeNotifier.value = _stageRemainingTime;

    if (newState != _currentBreathState) {
      _currentBreathState = newState;
      _breathingInstruction = newInstruction;
      _breathStateNotifier.value = _currentBreathState;
      _instructionNotifier.value = _breathingInstruction;
      _fadeController.reset();
      _fadeController.forward();

      // Play state change sound effect
      _playStateChangeSound(newState);

      // Cache color when state changes
      _lastBreathState = newState;
      _cachedBreathingColor = null; // Reset cache to recalculate
    }
  }

  void _checkMeditationCompletion() {
    int durationInSeconds;
    final durationParts = widget.meditation.duration.split(' ');
    final durationValue = int.parse(durationParts[0]);
    final durationUnit = durationParts[1].toLowerCase();

    if (durationUnit.startsWith('sec')) {
      durationInSeconds = durationValue;
    } else {
      durationInSeconds = durationValue * 60; // minutes to seconds
    }

    if (_seconds >= durationInSeconds * 10) {
      _completeMeditation();
    }
  }

  Future<void> _completeMeditation() async {
    _timer.cancel();
    _particleTicker.stop();

    // Stop both audio players properly
    try {
      await _audioPlayer.stop();
      await _stateChangeAudioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }

    final session = SessionHistory(
      date: DateTime.now(),
      duration: _seconds ~/ 10,
      meditationType: _getMeditationTypeForHistory(),
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

  Widget _buildEmotionButton(
      String emoji, String label, VoidCallback onPressed) {
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
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSessionAndExit() async {
    _timer.cancel();
    _particleTicker.stop();

    // Stop both audio players properly
    try {
      await _audioPlayer.stop();
      await _stateChangeAudioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping audio on exit: $e');
    }

    final session = SessionHistory(
      date: DateTime.now(),
      duration: _seconds ~/ 10,
      meditationType: _getMeditationTypeForHistory(),
    );
    await _meditationRepository.addSession(session);
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
            widget.breathingPattern.holdOutDuration) *
        10;

    final cyclePosition = _seconds % totalCycleDuration;

    switch (_currentBreathState) {
      case BreathingState.breatheIn:
        final progress =
            cyclePosition / (widget.breathingPattern.breatheInDuration * 10);
        return progress.clamp(0.0, 1.0);
      case BreathingState.holdIn:
        return 1.0;
      case BreathingState.breatheOut:
        final breathInHoldDuration =
            (widget.breathingPattern.breatheInDuration +
                    widget.breathingPattern.holdInDuration) *
                10;
        final progressInBreathOut = (cyclePosition - breathInHoldDuration) /
            (widget.breathingPattern.breatheOutDuration * 10);
        return (1.0 - progressInBreathOut).clamp(0.0, 1.0);
      case BreathingState.holdOut:
        return 0.0;
    }
  }

  Color _getBreathingStateColor() {
    // Use cached color if available and state hasn't changed
    if (_cachedBreathingColor != null &&
        _lastBreathState == _currentBreathState) {
      return _cachedBreathingColor!;
    }

    Color color;
    switch (_currentBreathState) {
      case BreathingState.breatheIn:
        color = const Color(0xFF8E97FD);
        break;
      case BreathingState.holdIn:
        color = const Color(0xFFFFCF86);
        break;
      case BreathingState.breatheOut:
        color = const Color(0xFFA1D1B0);
        break;
      case BreathingState.holdOut:
        color = const Color(0xFFB197FC);
        break;
    }

    _cachedBreathingColor = color;
    return color;
  }

  @override
  void dispose() {
    _timer.cancel();
    _particleTicker.stop();
    _breathingController.dispose();
    _particleController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    _audioPlayer.dispose();
    _stateChangeAudioPlayer.dispose();

    // Dispose all ValueNotifiers to prevent memory leaks
    _secondsNotifier.dispose();
    _cycleNotifier.dispose();
    _breathStateNotifier.dispose();
    _instructionNotifier.dispose();
    _progressNotifier.dispose();
    _stageRemainingTimeNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update particle system with actual screen dimensions
    final screenSize = MediaQuery.of(context).size;
    _particleSystem.updateScreenSize(screenSize.width, screenSize.height);

    return PopScope(
      canPop: false, // Prevent direct popping
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // Save session and then exit
          await _saveSessionAndExit();
          if (mounted) {
            widget.onClose();
          }
        }
      },
      child: Scaffold(
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
              // Optimized particle background with RepaintBoundary
              RepaintBoundary(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: OptimizedParticlePainter(_particleSystem),
                ),
              ),

              // Optimized wave background with RepaintBoundary
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _particleAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: OptimizedWavePainter(
                        _particleAnimation.value,
                        _getBreathingStateColor(),
                      ),
                    );
                  },
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Header with close button only
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _showExitDialog(),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.black26,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 24),
                            ),
                          ),
                          // Empty spacer to balance the layout
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Static session info at top
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          const SizedBox(height: 20),
                          // Stage countdown timer centered below title and subtitle
                          ValueListenableBuilder<int>(
                            valueListenable: _stageRemainingTimeNotifier,
                            builder: (context, remainingTime, child) {
                              return ValueListenableBuilder<BreathingState>(
                                valueListenable: _breathStateNotifier,
                                builder: (context, breathState, child) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getBreathingStateColor()
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: _getBreathingStateColor()
                                            .withOpacity(0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getStageIcon(breathState),
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${remainingTime}s',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
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

                            // Main breathing visualization - constrained to prevent overflow
                            Flexible(
                              flex: 2,
                              child: Center(
                                child: RepaintBoundary(
                                  child: AnimatedBuilder(
                                    animation: _breathingAnimation,
                                    builder: (context, child) {
                                      double progress = _getBreathingProgress();
                                      // Reduced max size to prevent overflow
                                      double size = 160 + (progress * 60);

                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Outer glow rings - smaller sizes
                                          for (int i = 3; i >= 1; i--)
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 800),
                                              width: size + (i * 20),
                                              height: size + (i * 20),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color:
                                                      _getBreathingStateColor()
                                                          .withOpacity(0.1 / i),
                                                  width: 2,
                                                ),
                                              ),
                                            ),

                                          // Main breathing orb
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            curve: Curves.easeInOutSine,
                                            width: size,
                                            height: size,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: [
                                                  _getBreathingStateColor()
                                                      .withOpacity(0.8),
                                                  _getBreathingStateColor()
                                                      .withOpacity(0.4),
                                                  _getBreathingStateColor()
                                                      .withOpacity(0.1),
                                                ],
                                                stops: const [0.0, 0.7, 1.0],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                      _getBreathingStateColor()
                                                          .withOpacity(0.4),
                                                  blurRadius: 30,
                                                  spreadRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Centered Text Widgets (Timer and Cycle)
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ValueListenableBuilder<int>(
                                                valueListenable:
                                                    _secondsNotifier,
                                                builder:
                                                    (context, seconds, child) {
                                                  return Text(
                                                    _formatTime(seconds ~/ 10),
                                                    style: const TextStyle(
                                                      fontSize: 28,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.white,
                                                      letterSpacing: 2.0,
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 6),
                                              ValueListenableBuilder<int>(
                                                valueListenable: _cycleNotifier,
                                                builder:
                                                    (context, cycle, child) {
                                                  return Text(
                                                    'Cycle $cycle',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
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
                                ),
                              ),
                            ),

                            // Breathing guide text with expand/shrink animation
                            ValueListenableBuilder<BreathingState>(
                              valueListenable: _breathStateNotifier,
                              builder: (context, breathState, child) {
                                return AnimatedBuilder(
                                  animation: _fadeAnimation,
                                  builder: (context, child) {
                                    // Get breathing progress for scaling animation
                                    double breathingProgress =
                                        _getBreathingProgress();
                                    double scale = 1.0;

                                    // Apply different scaling based on breathing state
                                    switch (breathState) {
                                      case BreathingState.breatheIn:
                                        scale = 1.0 +
                                            (breathingProgress *
                                                0.15); // Expand up to 15%
                                        break;
                                      case BreathingState.holdIn:
                                        scale = 1.15; // Stay expanded
                                        break;
                                      case BreathingState.breatheOut:
                                        scale = 1.15 -
                                            (breathingProgress *
                                                0.15); // Shrink back down
                                        break;
                                      case BreathingState.holdOut:
                                        scale = 1.0; // Stay at normal size
                                        break;
                                    }

                                    return Transform.scale(
                                      scale: scale,
                                      child: Opacity(
                                        opacity: _fadeAnimation.value * 0.7,
                                        child: Text(
                                          _getBreathingGuideText(breathState),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                Colors.white.withOpacity(0.6),
                                            letterSpacing: 0.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
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

  IconData _getStageIcon(BreathingState breathState) {
    switch (breathState) {
      case BreathingState.breatheIn:
        return Icons.keyboard_arrow_up;
      case BreathingState.holdIn:
        return Icons.pause;
      case BreathingState.breatheOut:
        return Icons.keyboard_arrow_down;
      case BreathingState.holdOut:
        return Icons.more_horiz;
    }
  }

  String _getMeditationTypeForHistory() {
    // Map the display titles to the expected meditation type keys for session history
    switch (widget.meditation.title.toLowerCase()) {
      case 'deep sleep':
        return 'sleep';
      case 'sharp focus':
        return 'focus';
      case 'calm mind':
        return 'anxiety';
      case 'joy & energy':
        return 'happiness';
      default:
        return 'meditation'; // fallback for any unmapped titles
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
                child: const Text('Continue',
                    style: TextStyle(color: Colors.white70)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _saveSessionAndExit();
                  if (mounted) {
                    widget.onClose();
                  }
                },
                child: const Text('End Session',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Optimized Particle System
class ParticleSystem {
  final int particleCount;
  double screenWidth;
  double screenHeight;
  final List<OptimizedParticle> particles = [];
  final math.Random _random = math.Random();

  bool needsRepaint = false;
  double _lastUpdateTime = 0;
  static const double _updateThreshold = 1.0 / 60.0; // 60 FPS cap

  ParticleSystem({
    required this.particleCount,
    required this.screenWidth,
    required this.screenHeight,
  }) {
    _initializeParticles();
  }

  void updateScreenSize(double width, double height) {
    screenWidth = width;
    screenHeight = height;
  }

  void _initializeParticles() {
    particles.clear();
    for (int i = 0; i < particleCount; i++) {
      particles.add(OptimizedParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        //TODO: PARTICLE_SPEED - Adjust these values to tune particle movement speed
        // Range: 0.005-0.015 = very slow, 0.01-0.03 = gentle, 0.02-0.05 = moderate
        speed: 0.008 +
            _random.nextDouble() *
                0.012, // Slightly slower, gentle movement for calming effect
        size: 1.5 + _random.nextDouble() * 3.5,
        opacity: 0.15 + _random.nextDouble() * 0.25,
        phase: _random.nextDouble() * 2 * math.pi, // For wave motion
      ));
    }
  }

  void update(double deltaTime, Color breathingColor) {
    if (deltaTime - _lastUpdateTime < _updateThreshold) {
      needsRepaint = false;
      return;
    }

    needsRepaint = false;
    _lastUpdateTime = deltaTime;

    for (var particle in particles) {
      final oldY = particle.y;

      //TODO: MOVEMENT_MULTIPLIER - Adjust this value to tune overall animation speed
      // Values: 0.2 = very slow, 0.3 = slow, 0.5 = gentle, 0.8 = moderate, 1.0 = fast
      particle.y -= particle.speed * 0.2; // Slower but visible movement

      //TODO: HORIZONTAL_WAVE - Adjust amplitude (0.001-0.005) and frequency (2-8) for wave motion
      // amplitude: 0.001 = subtle, 0.002 = gentle, 0.005 = noticeable
      // frequency: 2 = slow wave, 4 = gentle wave, 8 = quick wave
      particle.x += math.sin(particle.y * 4 + particle.phase) * 0.002;

      // Reset particle when it goes off screen
      if (particle.y < -0.05) {
        particle.y = 1.05;
        particle.x = _random.nextDouble();
        needsRepaint = true;
      }

      // Check if particle moved significantly
      if ((particle.y - oldY).abs() > 0.001) {
        needsRepaint = true;
      }

      // Keep particles within horizontal bounds
      if (particle.x < 0 || particle.x > 1) {
        particle.x = particle.x.clamp(0.0, 1.0);
      }
    }
  }
}

class OptimizedParticle {
  double x;
  double y;
  final double speed;
  final double size;
  final double opacity;
  final double phase;

  OptimizedParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.phase,
  });
}

// Optimized Custom Painters
class OptimizedParticlePainter extends CustomPainter {
  final ParticleSystem particleSystem;

  OptimizedParticlePainter(this.particleSystem);

  @override
  void paint(Canvas canvas, Size size) {
    if (particleSystem.particles.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false; // Disable anti-aliasing for better performance

    // Group particles by similar properties to reduce paint object creation
    for (var particle in particleSystem.particles) {
      // Use a simple circle without anti-aliasing for better performance
      paint.color = Colors.white.withOpacity(particle.opacity);

      canvas.drawCircle(
        Offset(
          particle.x * size.width,
          particle.y * size.height,
        ),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant OptimizedParticlePainter oldDelegate) {
    return particleSystem.needsRepaint;
  }
}

class OptimizedWavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  // Cache path and paint objects
  static final Path _path = Path();
  static final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..isAntiAlias = false;

  OptimizedWavePainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    //TODO: WAVE_APPEARANCE - Adjust wave visual properties
    // waveHeight: 10-30 = height of waves, waveCount: 1-3 = number of wave layers
    const waveHeight = 20.0;
    const waveCount = 2; // Reduced wave count for better performance
    final waveWidth = size.width;

    for (int i = 0; i < waveCount; i++) {
      _path.reset();
      final y = size.height * 0.5 + (i * 80);
      final opacity = 0.08 - (i * 0.02);

      _paint.color = color.withOpacity(opacity);

      // Optimize wave calculation - use fewer points
      for (double x = 0; x <= waveWidth; x += 8) {
        // Increased step for fewer points
        final waveY = y +
            math.sin((x / waveWidth * 2 * math.pi) +
                    (animationValue * 2 * math.pi) +
                    (i * 0.8)) *
                waveHeight;

        if (x == 0) {
          _path.moveTo(x, waveY);
        } else {
          _path.lineTo(x, waveY);
        }
      }

      canvas.drawPath(_path, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant OptimizedWavePainter oldDelegate) {
    // Always repaint for smooth wave animation
    return animationValue != oldDelegate.animationValue;
  }
}
