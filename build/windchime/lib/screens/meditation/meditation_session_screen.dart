import 'dart:async';
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
  static const transitionDuration = Duration(milliseconds: 500);
  static const transitionCurve = Curves.easeInOutCubic;
  late AnimationController _breathInController;
  late AnimationController _breathOutController;
  int _seconds = 0;
  late Timer _timer;
  late AudioPlayer _audioPlayer;
  BreathingState _currentBreathState = BreathingState.breatheIn;
  int _breathCounter = 0;
  String _breathingInstruction = 'Breathe In';

  @override
  void initState() {
    super.initState();
    _setupControllers();
    _setupAudio();
    _startMeditation();
  }

  Future<void> _setupAudio() async {
    _audioPlayer = AudioPlayer();

    try {
      await _audioPlayer
          .setAsset('assets/${widget.breathingPattern.audioPath}');
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _audioPlayer.dispose(); // Dispose the player if setup fails
    }
  }

  /// Set up the animation controllers for breathing in and out

  void _setupControllers() {
    _breathInController = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: widget.breathingPattern.breatheInDuration * 1000),
    );

    _breathOutController = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: widget.breathingPattern.breatheOutDuration * 1000),
    );

    _breathInController.forward();
  }

  void _startMeditation() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_breathCounter % 10 == 0) {
          _seconds++;
        }
        _breathCounter++;

        _updateBreathingState();
        _checkMeditationCompletion();
      });
    });
  }

  void _updateBreathingState() {
    // Ensure _breathCounter does not exceed expected values
    if (_breathCounter > widget.breathingPattern.breatheInTicks &&
        _currentBreathState == BreathingState.breatheIn) {
      _breathCounter = widget.breathingPattern.breatheInTicks;
    } else if (_breathCounter > widget.breathingPattern.holdInTicks &&
        _currentBreathState == BreathingState.holdIn) {
      _breathCounter = widget.breathingPattern.holdInTicks;
    } else if (_breathCounter > widget.breathingPattern.breatheOutTicks &&
        _currentBreathState == BreathingState.breatheOut) {
      _breathCounter = widget.breathingPattern.breatheOutTicks;
    } else if (_breathCounter > widget.breathingPattern.holdOutTicks &&
        _currentBreathState == BreathingState.holdOut) {
      _breathCounter = widget.breathingPattern.holdOutTicks;
    }

    if (_currentBreathState == BreathingState.breatheIn &&
        _breathCounter >= widget.breathingPattern.breatheInTicks) {
      setState(() {
        _currentBreathState = BreathingState.holdIn;
        _breathingInstruction = 'Hold';
        _breathCounter = 0;
        _breathInController.stop();
      });
    } else if (_currentBreathState == BreathingState.holdIn &&
        _breathCounter >= widget.breathingPattern.holdInTicks) {
      setState(() {
        _currentBreathState = BreathingState.breatheOut;
        _breathingInstruction = 'Breathe Out';
        _breathCounter = 0;
        _breathOutController.forward(from: 0.0);
      });
    } else if (_currentBreathState == BreathingState.breatheOut &&
        _breathCounter >= widget.breathingPattern.breatheOutTicks) {
      setState(() {
        _currentBreathState = BreathingState.holdOut;
        _breathingInstruction = 'Rest';
        _breathCounter = 0;
        _breathOutController.stop();
      });
    } else if (_currentBreathState == BreathingState.holdOut &&
        _breathCounter >= widget.breathingPattern.holdOutTicks) {
      setState(() {
        _currentBreathState = BreathingState.breatheIn;
        _breathingInstruction = 'Breathe In';
        _breathCounter = 0;
        _breathInController.forward(from: 0.0);
      });
    }
  }

  void _checkMeditationCompletion() {
    int durationInSeconds =
        int.parse(widget.meditation.duration.split(' ')[0]) * 60;
    if (_seconds >= durationInSeconds) {
      _completeMeditation();
    }
  }

  Future<void> _completeMeditation() async {
    _timer.cancel();
    _audioPlayer.stop();

    // Save session history
    final session = SessionHistory(
      date: DateTime.now(),
      duration: _seconds, // Store actual seconds
    );
    await _meditationRepository.addSession(session);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2031),
        title: const Text('Meditation Complete',
            style: TextStyle(color: Colors.white)),
        content: Text('How do you feel now?',
            style: TextStyle(color: Colors.white.withOpacity(0.8))),
        actions: [
          TextButton(
            child: Text('Great',
                style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onClose();
            },
          ),
          TextButton(
            child: Text('Relaxed',
                style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onClose();
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getBreathingGuide() {
    return switch (_currentBreathState) {
      BreathingState.breatheIn =>
        'Fill your lungs (${widget.breathingPattern.breatheInDuration}s)',
      BreathingState.holdIn =>
        'Hold your breath (${widget.breathingPattern.holdInDuration}s)',
      BreathingState.breatheOut =>
        'Release slowly (${widget.breathingPattern.breatheOutDuration}s)',
      BreathingState.holdOut =>
        'Rest (${widget.breathingPattern.holdOutDuration}s)',
    };
  }

  String _getBreathCountdown() {
    final remaining = switch (_currentBreathState) {
          BreathingState.breatheIn => widget.breathingPattern.breatheInDuration,
          BreathingState.holdIn => widget.breathingPattern.holdInDuration,
          BreathingState.breatheOut =>
            widget.breathingPattern.breatheOutDuration,
          BreathingState.holdOut => widget.breathingPattern.holdOutDuration,
        } -
        (_breathCounter ~/ 10);

    return remaining > 0 ? '$remaining' : '0';
  }

  Color _getBreathingStateColor() {
    return switch (_currentBreathState) {
      BreathingState.breatheIn => const Color(0xFF8E97FD),
      BreathingState.holdIn => const Color(0xFFFFCF86),
      BreathingState.breatheOut => const Color(0xFFA1D1B0),
      BreathingState.holdOut => const Color(0xFFB197FC),
    };
  }

  @override
  void dispose() {
    // Cancel the timer if it's active
    if (_timer.isActive) {
      _timer.cancel();
    }

    // Stop and dispose animation controllers
    _breathInController.stop();
    _breathInController.dispose();
    _breathOutController.stop();
    _breathOutController.dispose();

    // Dispose the audio player if initialized
    _audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.breathingPattern.primaryColor,
            const Color(0xFF1A1B2E),
          ],
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
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () async {
                      // Stop timer and audio
                      _timer.cancel();
                      _audioPlayer.stop();

                      // Save session when manually closed
                      final session = SessionHistory(
                        date: DateTime.now(),
                        duration: _seconds, // Store actual seconds
                      );
                      await _meditationRepository.addSession(session);

                      widget.onClose();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: transitionDuration,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.2),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: transitionCurve,
                          )),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      _breathingInstruction,
                      key: ValueKey(_breathingInstruction),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFF212121)
                                    : Colors.white,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.meditation.title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xFF212121)
                                  : Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.breathingPattern.name} - ${_getBreathingGuide()}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xFF212121)
                                  : Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_breathInController, _breathOutController]),
                    builder: (context, child) {
                      double size;
                      if (_currentBreathState == BreathingState.breatheIn) {
                        size = 200 + 40 * _breathInController.value;
                      } else if (_currentBreathState ==
                          BreathingState.breatheOut) {
                        size = 240 - 40 * _breathOutController.value;
                      } else if (_currentBreathState == BreathingState.holdIn) {
                        size = 240;
                      } else {
                        size = 200;
                      }

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: transitionDuration,
                            curve: transitionCurve,
                            width: size + 20,
                            height: size + 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _getBreathingStateColor().withOpacity(0.08),
                            ),
                          ),
                          AnimatedContainer(
                            duration: transitionDuration,
                            curve: transitionCurve,
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _getBreathingStateColor().withOpacity(0.12),
                            ),
                          ),
                          AnimatedContainer(
                            duration: transitionDuration,
                            curve: transitionCurve,
                            width: size * 0.75,
                            height: size * 0.75,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _getBreathingStateColor().withOpacity(0.9),
                                  _getBreathingStateColor(),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getBreathingStateColor()
                                      .withOpacity(0.5),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatTime(_seconds),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? const Color(0xFF212121)
                                              : Colors.white,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _getBreathCountdown(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontSize: 14,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? const Color(0xFF212121)
                                              : Colors.white,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
