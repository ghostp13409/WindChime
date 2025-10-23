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
  final bool useVoiceCues;

  const OptimizedMeditationSessionScreen({
    super.key,
    required this.breathingPattern,
    required this.meditation,
    required this.onClose,
    this.useVoiceCues = false,
  });

  @override
  State<OptimizedMeditationSessionScreen> createState() =>
      _OptimizedMeditationSessionScreenState();
}

class _OptimizedMeditationSessionScreenState
    extends State<OptimizedMeditationSessionScreen>
    with TickerProviderStateMixin {
  final _meditationRepository = MeditationRepository();

  late AnimationController _breathingController;
  late AnimationController _particleController;
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late AnimationController _glowController;

  late Animation<double> _breathingAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  final ValueNotifier<int> _secondsNotifier = ValueNotifier(0);
  final ValueNotifier<int> _cycleNotifier = ValueNotifier(0);
  final ValueNotifier<BreathingState> _breathStateNotifier =
      ValueNotifier(BreathingState.breatheIn);
  final ValueNotifier<String> _instructionNotifier =
      ValueNotifier('Breathe In');
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);
  final ValueNotifier<int> _stageRemainingTimeNotifier = ValueNotifier(0);

  int _seconds = 0;
  Timer? _timer;
  late AudioPlayer _audioPlayer;
  late AudioPlayer _stateChangeAudioPlayer;
  BreathingState _currentBreathState = BreathingState.breatheIn;
  String _breathingInstruction = 'Breathe In';
  int _currentCycle = 0;
  double _sessionProgress = 0.0;
  int _stageRemainingTime = 0;

  bool _isPreparing = true;
  int _countdown = 3;
  Timer? _preparationTimer;

  late ParticleSystem _particleSystem;
  late Ticker _particleTicker;
  int _frameCount = 0;

  Color? _cachedBreathingColor;
  BreathingState? _lastBreathState;

  static const Map<String, Map<BreathingState, Color>> _colorSchemes = {
    'sleep': {
      BreathingState.breatheIn: Color(0xFF9B87E8), // Light purple (brighter)
      BreathingState.holdIn: Color(0xFF7B65E4), // Primary purple
      BreathingState.breatheOut: Color(0xFF5D4E9C), // Dark purple (darker)
      BreathingState.holdOut: Color(0xFF6A5ACD), // Slate blue
    },
    'focus': {
      BreathingState.breatheIn: Color(0xFFFF8A65), // Light orange (brighter)
      BreathingState.holdIn: Color(0xFFF6815B), // Primary orange
      BreathingState.breatheOut: Color(0xFFE65100), // Deep orange (darker)
      BreathingState.holdOut: Color(0xFFD84315), // Red orange
    },
    'anxiety': {
      BreathingState.breatheIn: Color(0xFF66BB6A), // Light green (brighter)
      BreathingState.holdIn: Color(0xFF4CAF50), // Primary green
      BreathingState.breatheOut: Color(0xFF2E7D32), // Dark green (darker)
      BreathingState.holdOut: Color(0xFF388E3C), // Medium green
    },
    'happiness': {
      BreathingState.breatheIn: Color(0xFFFFE082), // Light yellow (brighter)
      BreathingState.holdIn: Color(0xFFFFCF86), // Primary yellow
      BreathingState.breatheOut:
          Color(0xFFB8860B), // Dull gold (duller and dimmer)
      BreathingState.holdOut: Color(0xFFFFB300), // Amber
    },
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupOptimizedParticleSystem();
    _setupAudio();
    _setupStateChangeAudio();
    _startPreparation();
  }

  void _setupAnimations() {
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

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _particleAnimation = _particleController;

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutCubic,
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );

    _breathingController.repeat();
    _particleController.repeat();
    _glowController.repeat(reverse: true);
    _fadeController.forward();
  }

  void _setupOptimizedParticleSystem() {
    _particleSystem = ParticleSystem(
      particleCount: 20,
      screenWidth: 400,
      screenHeight: 800,
    );

    _particleTicker = createTicker(_updateParticles);
    _particleTicker.start();
  }

  void _updateParticles(Duration elapsed) {
    _frameCount++;
    if (_frameCount % 1 == 0) {
      final deltaTime = elapsed.inMilliseconds / 1000.0;
      _particleSystem.update(deltaTime, _getBreathingStateColor());
      if (_particleSystem.needsRepaint) {
        setState(() {});
      }
    }
  }

  Future<void> _setupAudio() async {
    _audioPlayer = AudioPlayer();
    try {
      await _audioPlayer.setVolume(0.1);
      await _audioPlayer
          .setAsset('assets/${widget.breathingPattern.audioPath}');
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
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
      if (widget.useVoiceCues) {
        switch (state) {
          case BreathingState.breatheIn:
            soundPath =
                'assets/sounds/meditation/statechange/breathe_in_voice.wav';
            break;
          case BreathingState.holdIn:
            soundPath = 'assets/sounds/meditation/statechange/hold_voice.wav';
            break;
          case BreathingState.breatheOut:
            soundPath =
                'assets/sounds/meditation/statechange/breathe_out_voice.wav';
            break;
          case BreathingState.holdOut:
            soundPath = 'assets/sounds/meditation/statechange/rest_voice.wav';
            break;
        }
      } else {
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
      }
      if (_stateChangeAudioPlayer.playing) {
        await _stateChangeAudioPlayer.stop();
      }
      await _stateChangeAudioPlayer.setVolume(widget.useVoiceCues ? 0.5 : 1.0);
      await _stateChangeAudioPlayer.setAsset(soundPath);
      await _stateChangeAudioPlayer.seek(Duration.zero);
      _stateChangeAudioPlayer.play().catchError((error) {
        debugPrint('Error during audio playback: $error');
      });
    } catch (e) {
      debugPrint('Error playing state change sound: $e');
    }
  }

  void _startPreparation() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        await _stateChangeAudioPlayer.setVolume(0.5);
        await _stateChangeAudioPlayer
            .setAsset('assets/sounds/meditation/statechange/get_ready.wav');
        await _stateChangeAudioPlayer.seek(Duration.zero);
        _stateChangeAudioPlayer.play().catchError((error) {
          debugPrint('Error during get ready audio playback: $error');
        });
      } catch (e) {
        debugPrint('Error playing get ready sound: $e');
      }
    });

    _preparationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        _preparationTimer?.cancel();
        setState(() {
          _isPreparing = false;
        });
        _startMeditation();
      }
    });
  }

  void _skipPreparation() {
    _preparationTimer?.cancel();
    setState(() {
      _isPreparing = false;
    });
    _startMeditation();
  }

  void _startMeditation() {
    // Play initial breathe in sound
    _playStateChangeSound(BreathingState.breatheIn);

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
      totalDurationInSeconds = durationValue * 60;
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

    _stageRemainingTime = stageRemainingTime;
    _stageRemainingTimeNotifier.value = _stageRemainingTime;

    if (newState != _currentBreathState) {
      _currentBreathState = newState;
      _breathingInstruction = newInstruction;
      _breathStateNotifier.value = _currentBreathState;
      _instructionNotifier.value = _breathingInstruction;
      _fadeController.reset();
      _fadeController.forward();
      _playStateChangeSound(newState);
      _lastBreathState = newState;
      _cachedBreathingColor = null;
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
      durationInSeconds = durationValue * 60;
    }

    if (_seconds >= durationInSeconds * 10) {
      _completeMeditation();
    }
  }

  Future<void> _completeMeditation() async {
    _timer?.cancel();
    _particleTicker.stop();
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
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isLightTheme
            ? Theme.of(context).cardColor
            : const Color(0xFF1C2031).withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '🧘‍♀️ Session Complete',
          style: TextStyle(
              color: isLightTheme ? Colors.black87 : Colors.white,
              fontSize: 24),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How are you feeling?',
              style: TextStyle(
                  color: isLightTheme ? Colors.black54 : Colors.white70,
                  fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<int>(
              valueListenable: _secondsNotifier,
              builder: (context, seconds, child) {
                return Text(
                  'Duration: ${_formatTime(seconds ~/ 10)}',
                  style: TextStyle(
                      color: isLightTheme ? Colors.black45 : Colors.white60,
                      fontSize: 14),
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
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border:
              Border.all(color: isLightTheme ? Colors.black26 : Colors.white30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: isLightTheme ? Colors.black54 : Colors.white70,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSessionAndExit() async {
    _timer?.cancel();
    _particleTicker.stop();
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
    return 0.0;
  }

  Color _getBreathingStateColor() {
    if (_cachedBreathingColor != null &&
        _lastBreathState == _currentBreathState) {
      return _cachedBreathingColor!;
    }

    String type = _getMeditationTypeForHistory();
    Color color = _colorSchemes[type]?[_currentBreathState] ??
        _getDefaultBreathingStateColor(_currentBreathState);

    _cachedBreathingColor = color;
    return color;
  }

  Color _getDefaultBreathingStateColor(BreathingState state) {
    switch (state) {
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
        return 'meditation';
    }
  }

  void _showExitDialog() {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isLightTheme
            ? Theme.of(context).cardColor
            : const Color(0xFF1C2031).withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'End Session?',
          style: TextStyle(color: isLightTheme ? Colors.black87 : Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Your progress will be saved',
          style:
              TextStyle(color: isLightTheme ? Colors.black54 : Colors.white70),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Continue',
                    style: TextStyle(
                        color: isLightTheme ? Colors.black54 : Colors.white70)),
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

  Widget _buildPreparationScreen() {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    final gradientColors = isLightTheme
        ? [
            widget.breathingPattern.primaryColor.withOpacity(0.8),
            const Color(0xFFFFFFFF),
            const Color(0xFFE3F2F1),
          ]
        : [
            widget.breathingPattern.primaryColor.withOpacity(0.8),
            const Color(0xFF0F1419),
            const Color(0xFF1A1B2E),
          ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
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
                          color: isLightTheme
                              ? Colors.white.withOpacity(0.5)
                              : Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close,
                            color: isLightTheme ? Colors.black : Colors.white,
                            size: 24),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Ready',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: isLightTheme ? Colors.black87 : Colors.white,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        '$_countdown',
                        style: TextStyle(
                          fontSize: 120,
                          fontWeight: FontWeight.w200,
                          color: isLightTheme ? Colors.black87 : Colors.white,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Find a comfortable position\nand prepare to breathe',
                        style: TextStyle(
                          fontSize: 18,
                          color: isLightTheme
                              ? Colors.black54
                              : Colors.white.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _skipPreparation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor:
                          isLightTheme ? Colors.black87 : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isLightTheme ? Colors.black26 : Colors.white30,
                          width: 1,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _preparationTimer?.cancel();
    _particleTicker.stop();
    _breathingController.dispose();
    _particleController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    _glowController.dispose();
    _audioPlayer.dispose();
    _stateChangeAudioPlayer.dispose();

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
    if (_isPreparing) {
      return _buildPreparationScreen();
    }

    final screenSize = MediaQuery.of(context).size;
    _particleSystem.updateScreenSize(screenSize.width, screenSize.height);

    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    final gradientColors = isLightTheme
        ? [
            widget.breathingPattern.primaryColor.withOpacity(0.8),
            const Color(0xFFFFFFFF),
            const Color(0xFFE3F2F1),
          ]
        : [
            widget.breathingPattern.primaryColor.withOpacity(0.8),
            const Color(0xFF0F1419),
            const Color(0xFF1A1B2E),
          ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
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
              colors: gradientColors,
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: OptimizedParticlePainter(_particleSystem,
                      isLightTheme: isLightTheme),
                ),
              ),
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
                                color: isLightTheme
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.black26,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close,
                                  color: isLightTheme
                                      ? Colors.black
                                      : Colors.white,
                                  size: 24),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            widget.meditation.title,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              color:
                                  isLightTheme ? Colors.black87 : Colors.white,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.breathingPattern.name,
                            style: TextStyle(
                              fontSize: 16,
                              color: isLightTheme
                                  ? Colors.black54
                                  : Colors.white.withOpacity(0.7),
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ValueListenableBuilder<int>(
                            valueListenable: _secondsNotifier,
                            builder: (context, seconds, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(isLightTheme ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  _formatTime(seconds ~/ 10),
                                  style: TextStyle(
                                    color: isLightTheme
                                        ? Colors.black87
                                        : Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.0,
                                  ),
                                ),
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
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w400,
                                          color: isLightTheme
                                              ? Colors.black87
                                              : Colors.white,
                                          letterSpacing: 1.0,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            Flexible(
                              flex: 2,
                              child: Center(
                                child: RepaintBoundary(
                                  child: AnimatedBuilder(
                                    animation: Listenable.merge(
                                        [_breathingAnimation, _glowAnimation]),
                                    builder: (context, child) {
                                      double progress = _getBreathingProgress();
                                      double size = 160 + (progress * 60);
                                      double glowBlur =
                                          20 + (_glowAnimation.value * 20);

                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
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
                                          Container(
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
                                                  blurRadius: glowBlur,
                                                  spreadRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Transform.scale(
                                            scale: size / 160,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ValueListenableBuilder<int>(
                                                  valueListenable:
                                                      _stageRemainingTimeNotifier,
                                                  builder: (context,
                                                      remainingTime, child) {
                                                    return ValueListenableBuilder<
                                                        BreathingState>(
                                                      valueListenable:
                                                          _breathStateNotifier,
                                                      builder: (context,
                                                          breathState, child) {
                                                        return Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              _getStageIcon(
                                                                  breathState),
                                                              color: isLightTheme
                                                                  ? Colors
                                                                      .black87
                                                                  : Colors
                                                                      .white,
                                                              size: 24,
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            Text(
                                                              '${remainingTime}s',
                                                              style: TextStyle(
                                                                color: isLightTheme
                                                                    ? Colors
                                                                        .black87
                                                                    : Colors
                                                                        .white,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                letterSpacing:
                                                                    0.5,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                                const SizedBox(height: 6),
                                                ValueListenableBuilder<int>(
                                                  valueListenable:
                                                      _cycleNotifier,
                                                  builder:
                                                      (context, cycle, child) {
                                                    return Text(
                                                      'Cycle $cycle',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: isLightTheme
                                                            ? Colors.black54
                                                            : Colors.white
                                                                .withOpacity(
                                                                    0.8),
                                                        letterSpacing: 1.0,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            ValueListenableBuilder<BreathingState>(
                              valueListenable: _breathStateNotifier,
                              builder: (context, breathState, child) {
                                return AnimatedBuilder(
                                  animation: _fadeAnimation,
                                  builder: (context, child) {
                                    double breathingProgress =
                                        _getBreathingProgress();
                                    double scale = 1.0;
                                    switch (breathState) {
                                      case BreathingState.breatheIn:
                                        scale =
                                            1.0 + (breathingProgress * 0.15);
                                        break;
                                      case BreathingState.holdIn:
                                        scale = 1.15;
                                        break;
                                      case BreathingState.breatheOut:
                                        scale =
                                            1.15 - (breathingProgress * 0.15);
                                        break;
                                      case BreathingState.holdOut:
                                        scale = 1.0;
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
                                            color: isLightTheme
                                                ? Colors.black54
                                                : Colors.white.withOpacity(0.6),
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
}

class ParticleSystem {
  final int particleCount;
  double screenWidth;
  double screenHeight;
  final List<OptimizedParticle> particles = [];
  final math.Random _random = math.Random();

  bool needsRepaint = false;
  double _lastUpdateTime = 0;
  static const double _updateThreshold = 1.0 / 60.0;

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
        speed: 0.008 + _random.nextDouble() * 0.012,
        size: 1.5 + _random.nextDouble() * 3.5,
        opacity: 0.15 + _random.nextDouble() * 0.25,
        phase: _random.nextDouble() * 2 * math.pi,
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
      particle.y -= particle.speed * 0.2;
      particle.x += math.sin(particle.y * 4 + particle.phase) * 0.002;
      if (particle.y < -0.05) {
        particle.y = 1.05;
        particle.x = _random.nextDouble();
        needsRepaint = true;
      }
      if ((particle.y - oldY).abs() > 0.001) {
        needsRepaint = true;
      }
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

class OptimizedParticlePainter extends CustomPainter {
  final ParticleSystem particleSystem;
  final bool isLightTheme;

  OptimizedParticlePainter(this.particleSystem, {required this.isLightTheme});

  @override
  void paint(Canvas canvas, Size size) {
    if (particleSystem.particles.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    for (var particle in particleSystem.particles) {
      paint.color = (isLightTheme ? Colors.black : Colors.white)
          .withOpacity(particle.opacity);

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
    return particleSystem.needsRepaint ||
        isLightTheme != oldDelegate.isLightTheme;
  }
}

class OptimizedWavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  static final Path _path = Path();
  static final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..isAntiAlias = false;

  OptimizedWavePainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const waveHeight = 20.0;
    const waveCount = 2;
    final waveWidth = size.width;

    for (int i = 0; i < waveCount; i++) {
      _path.reset();
      final y = size.height * 0.5 + (i * 80);
      final opacity = 0.08 - (i * 0.02);

      _paint.color = color.withOpacity(opacity);

      for (double x = 0; x <= waveWidth; x += 8) {
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
    return animationValue != oldDelegate.animationValue;
  }
}
