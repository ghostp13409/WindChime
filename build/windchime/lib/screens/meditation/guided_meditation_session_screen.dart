import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:windchime/data/repositories/meditation_repository.dart';
import 'package:windchime/models/meditation/session_history.dart';

class GuidedMeditationSessionScreen extends StatefulWidget {
  final String title;
  final String duration;
  final String description;
  final String audioPath;
  final String source;
  final Color categoryColor;

  const GuidedMeditationSessionScreen({
    super.key,
    required this.title,
    required this.duration,
    required this.description,
    required this.audioPath,
    required this.source,
    required this.categoryColor,
  });

  @override
  State<GuidedMeditationSessionScreen> createState() =>
      _GuidedMeditationSessionScreenState();
}

class _GuidedMeditationSessionScreenState
    extends State<GuidedMeditationSessionScreen> with TickerProviderStateMixin {
  final _meditationRepository = MeditationRepository();

  // Audio player
  late AudioPlayer _audioPlayer;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  // Session state
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Timer for UI updates
  Timer? _positionTimer;

  // Stream subscriptions for proper cleanup
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupAudioPlayer();
  }

  void _setupAnimations() {
    // Fade animation for transitions
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Pulse animation for play button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  Future<void> _setupAudioPlayer() async {
    _audioPlayer = AudioPlayer();

    try {
      // Set up audio source
      await _audioPlayer.setAsset('assets/${widget.audioPath}');

      // Listen to player state changes with managed subscription
      _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            _isLoading = state.processingState == ProcessingState.loading ||
                state.processingState == ProcessingState.buffering;
          });

          // Handle completion
          if (state.processingState == ProcessingState.completed) {
            _onMeditationComplete();
          }
        }
      });

      // Listen to duration changes with managed subscription
      _durationSubscription = _audioPlayer.durationStream.listen((duration) {
        if (mounted && duration != null) {
          setState(() {
            _totalDuration = duration;
            _isLoading = false;
          });
          // Auto-start playing when duration is loaded
          _autoStartPlayback();
        }
      });

      // Listen to position changes with managed subscription
      _positionSubscription = _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
          _updateProgress();
        }
      });

      // Start position timer for smooth updates
      _startPositionTimer();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load audio: $e';
        });
      }
      debugPrint('Error setting up audio: $e');
    }
  }

  void _startPositionTimer() {
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && _isPlaying) {
        _updateProgress();
      }
    });
  }

  void _updateProgress() {
    if (_totalDuration.inMilliseconds > 0) {
      final progress =
          _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
      _progressController.animateTo(progress.clamp(0.0, 1.0));
    }
  }

  Future<void> _autoStartPlayback() async {
    try {
      // Automatically start playing when the audio is ready
      await _audioPlayer.play();
      _pulseController.repeat(reverse: true);
    } catch (e) {
      debugPrint('Error auto-starting playback: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      HapticFeedback.lightImpact();

      if (_isPlaying) {
        await _audioPlayer.pause();
        _pulseController.stop();
      } else {
        await _audioPlayer.play();
        _pulseController.repeat(reverse: true);
      }
    } catch (e) {
      debugPrint('Error toggling playback: $e');
      _showErrorSnackBar('Playback error: $e');
    }
  }

  Future<void> _seekTo(double progress) async {
    try {
      final position = Duration(
        milliseconds: (_totalDuration.inMilliseconds * progress).round(),
      );
      await _audioPlayer.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  Future<void> _skipForward() async {
    try {
      HapticFeedback.selectionClick();
      final newPosition = _currentPosition + const Duration(seconds: 5);
      final targetPosition =
          newPosition > _totalDuration ? _totalDuration : newPosition;
      await _audioPlayer.seek(targetPosition);
    } catch (e) {
      debugPrint('Error skipping forward: $e');
    }
  }

  Future<void> _skipBackward() async {
    try {
      HapticFeedback.selectionClick();
      final newPosition = _currentPosition - const Duration(seconds: 5);
      final targetPosition =
          newPosition < Duration.zero ? Duration.zero : newPosition;
      await _audioPlayer.seek(targetPosition);
    } catch (e) {
      debugPrint('Error skipping backward: $e');
    }
  }

  Future<void> _onMeditationComplete() async {
    try {
      _pulseController.stop();
      _positionTimer?.cancel();

      // Save session to history
      final session = SessionHistory(
        date: DateTime.now(),
        duration: _totalDuration.inSeconds,
        meditationType:
            'guided_${widget.title.toLowerCase().replaceAll(' ', '_')}',
      );

      await _meditationRepository.addSession(session);

      if (mounted) {
        _showCompletionDialog();
      }
    } catch (e) {
      debugPrint('Error completing meditation: $e');
      if (mounted) {
        _showCompletionDialog();
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '🧘‍♀️ Session Complete',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How are you feeling?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.withOpacity(0.8),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Duration: ${_formatDuration(_totalDuration)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.categoryColor.withOpacity(0.3),
            width: 1,
          ),
          color: widget.categoryColor.withOpacity(0.1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.categoryColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _closeSession() {
    Navigator.of(context).pop(); // Close dialog
    Navigator.of(context).pop(); // Close session screen
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'End Session?',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Your progress will be saved',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.withOpacity(0.8),
              ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Continue',
                  style: TextStyle(color: widget.categoryColor),
                ),
              ),
              TextButton(
                onPressed: () => _endSessionSafely(),
                child: const Text(
                  'End Session',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _endSessionSafely() async {
    try {
      // Close the dialog first
      Navigator.of(context).pop();

      // Cancel stream subscriptions to prevent crashes
      _playerStateSubscription?.cancel();
      _durationSubscription?.cancel();
      _positionSubscription?.cancel();

      // Stop animations and timers
      _pulseController.stop();
      _positionTimer?.cancel();

      // Stop audio player safely
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      }
      await _audioPlayer.stop();

      // Save partial session
      final session = SessionHistory(
        date: DateTime.now(),
        duration: _currentPosition.inSeconds,
        meditationType:
            'guided_${widget.title.toLowerCase().replaceAll(' ', '_')}_partial',
      );
      await _meditationRepository.addSession(session);

      // Close session screen
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error ending session safely: $e');
      // Force close even if there's an error
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    // Cancel timer first
    _positionTimer?.cancel();

    // Cancel stream subscriptions to prevent memory leaks
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();

    // Stop animations
    _pulseController.stop();
    _fadeController.stop();
    _progressController.stop();

    // Dispose audio player safely
    try {
      if (_audioPlayer.playing) {
        _audioPlayer.pause();
      }
      _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping audio in dispose: $e');
    } finally {
      _audioPlayer.dispose();
    }

    // Dispose animation controllers
    _fadeController.dispose();
    _pulseController.dispose();
    _progressController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showExitDialog();
        return false; // Prevent immediate pop, let dialog handle it
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.categoryColor.withOpacity(0.15),
                Theme.of(context).colorScheme.background,
                Theme.of(context).colorScheme.background,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header with back button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.2),
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
                              _showExitDialog();
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: Theme.of(context)
                                  .iconTheme
                                  .color
                                  ?.withOpacity(0.8),
                            ),
                            iconSize: 22,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Guided Meditation',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                              Text(
                                'Focus and relax',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey.withOpacity(0.8),
                                      letterSpacing: 0.2,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Session Info
                          _buildSessionInfo(),

                          const SizedBox(height: 40),

                          // Main visualization
                          Expanded(child: _buildVisualization()),

                          const SizedBox(height: 40),

                          // Progress bar
                          _buildProgressBar(),

                          const SizedBox(height: 24),

                          // Controls
                          _buildControls(),

                          const SizedBox(height: 32),
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

  Widget _buildSessionInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.withOpacity(0.8),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.duration,
                  style: TextStyle(
                    color: widget.categoryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'by ${widget.source}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.withOpacity(0.6),
                        fontSize: 11,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisualization() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Audio Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.withOpacity(0.8),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPlaying ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.categoryColor.withOpacity(0.3),
                    widget.categoryColor.withOpacity(0.1),
                    widget.categoryColor.withOpacity(0.05),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.categoryColor.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatDuration(_currentPosition),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2.0,
                          color: widget.categoryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _totalDuration.inSeconds > 0
                        ? '/ ${_formatDuration(_totalDuration)}'
                        : 'Loading...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.withOpacity(0.6),
                          letterSpacing: 1.0,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(widget.categoryColor),
              minHeight: 6,
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_currentPosition),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.withOpacity(0.6),
                  ),
            ),
            Text(
              _formatDuration(_totalDuration),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Skip backward
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _isLoading ? null : _skipBackward,
            icon: const Icon(Icons.replay_5),
            iconSize: 28,
            padding: const EdgeInsets.all(16),
          ),
        ),

        // Play/Pause button
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.categoryColor,
                widget.categoryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: widget.categoryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _isLoading ? null : _togglePlayPause,
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
            iconSize: 32,
            padding: const EdgeInsets.all(20),
          ),
        ),

        // Skip forward
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _isLoading ? null : _skipForward,
            icon: const Icon(Icons.forward_5),
            iconSize: 28,
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
