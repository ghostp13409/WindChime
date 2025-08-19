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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:windchime/data/repositories/meditation_repository.dart';
import 'package:windchime/models/meditation/session_history.dart';
import 'package:windchime/services/audio_download_service.dart';
import 'package:windchime/config/audio_config.dart';

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
  final _downloadService = AudioDownloadService();

  // Audio player
  late AudioPlayer _audioPlayer;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _playPauseController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _playPauseAnimation;

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

    // Play/pause transition animation
    _playPauseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _playPauseAnimation = CurvedAnimation(
      parent: _playPauseController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
  }

  Future<void> _setupAudioPlayer() async {
    _audioPlayer = AudioPlayer();

    try {
      // Determine the correct audio source
      String? audioSource;

      if (AudioConfig.shouldDownload(widget.audioPath)) {
        // For downloadable files, get the local file path
        audioSource = await _downloadService.getAudioFilePath(widget.audioPath);
        await _audioPlayer.setFilePath(audioSource!);
      } else {
        // For bundled files, use asset path
        audioSource = 'assets/${widget.audioPath}';
        await _audioPlayer.setAsset(audioSource);
      }

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

      // Trigger play/pause transition animation
      if (_isPlaying) {
        _playPauseController.reverse();
        await _audioPlayer.pause();
        _pulseController.stop();
      } else {
        _playPauseController.forward();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.categoryColor.withOpacity(0.2),
                    widget.categoryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 40,
                color: widget.categoryColor,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Session Complete!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'How are you feeling?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Duration: ${_formatDuration(_totalDuration)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: widget.categoryColor,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

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
      ),
    );
  }

  Widget _buildEmotionButton(
      String emoji, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.categoryColor.withOpacity(0.3),
            width: 1,
          ),
          color: widget.categoryColor.withOpacity(0.08),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.categoryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
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
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pause icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.2),
                    Colors.orange.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.pause_circle_outline,
                size: 40,
                color: Colors.orange.shade600,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Pause Your Session?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Your meditation progress will be automatically saved.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildExitDialogButton(
                    'Continue', true, () => Navigator.of(context).pop()),
                _buildExitDialogButton(
                    'End Session', false, () => _endSessionSafely()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExitDialogButton(
      String label, bool isPrimary, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPrimary
                ? widget.categoryColor.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
          color: isPrimary
              ? widget.categoryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isPrimary ? widget.categoryColor : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
          textAlign: TextAlign.center,
        ),
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
    _playPauseController.stop();

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
    _playPauseController.dispose();

    super.dispose();
  }

  Widget _buildCompactSessionInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.categoryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.categoryColor.withOpacity(0.2),
                  widget.categoryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.headset,
              color: widget.categoryColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'by ${widget.source}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.withOpacity(0.7),
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),

          // Duration badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.categoryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.duration,
              style: TextStyle(
                color: widget.categoryColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineProgress() {
    return Column(
      children: [
        // Time row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_currentPosition),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.categoryColor,
                  ),
            ),
            Text(
              _totalDuration.inSeconds > 0
                  ? _formatDuration(_totalDuration)
                  : 'Loading...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.withOpacity(0.7),
                  ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Progress bar (left to right)
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.grey.withOpacity(0.2),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: MediaQuery.of(context).size.width *
                      0.8 *
                      _progressAnimation.value,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [
                        widget.categoryColor,
                        widget.categoryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompactControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip backward
        _buildCompactControlButton(
          icon: Icons.replay_5,
          onPressed: _isLoading ? null : _skipBackward,
          isSecondary: true,
        ),

        const SizedBox(width: 24),

        // Play/Pause button (larger)
        _buildCompactControlButton(
          icon: _isLoading
              ? null
              : _isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
          onPressed: _isLoading ? null : _togglePlayPause,
          isSecondary: false,
          isLoading: _isLoading,
        ),

        const SizedBox(width: 24),

        // Skip forward
        _buildCompactControlButton(
          icon: Icons.forward_5,
          onPressed: _isLoading ? null : _skipForward,
          isSecondary: true,
        ),
      ],
    );
  }

  Widget _buildCompactControlButton({
    IconData? icon,
    VoidCallback? onPressed,
    required bool isSecondary,
    bool isLoading = false,
  }) {
    final isDisabled = onPressed == null;
    final size = isSecondary ? 48.0 : 64.0;
    final iconSize = isSecondary ? 20.0 : 28.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: isSecondary
            ? null
            : LinearGradient(
                colors: [
                  widget.categoryColor,
                  widget.categoryColor.withOpacity(0.8),
                ],
              ),
        color: isSecondary ? Theme.of(context).colorScheme.surface : null,
        borderRadius: BorderRadius.circular(size / 3),
        border: isSecondary
            ? Border.all(
                color: widget.categoryColor.withOpacity(0.3),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isSecondary
                ? Colors.black.withOpacity(0.05)
                : widget.categoryColor.withOpacity(0.3),
            blurRadius: isSecondary ? 8 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 3),
          onTap: onPressed,
          child: Container(
            child: isLoading
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isSecondary ? widget.categoryColor : Colors.white,
                      ),
                    ),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      icon,
                      key: ValueKey(icon),
                      color: isSecondary ? widget.categoryColor : Colors.white,
                      size: iconSize,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          // Back button with glassmorphism effect
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.categoryColor.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
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
                color: Theme.of(context).iconTheme.color?.withOpacity(0.8),
              ),
              iconSize: 20,
              padding: const EdgeInsets.all(14),
            ),
          ),

          const SizedBox(width: 20),

          // Title section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guided Session',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Theme.of(context).textTheme.headlineSmall?.color,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mindful awareness practice',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: widget.categoryColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
          ),

          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.categoryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.categoryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _isPlaying
                        ? Colors.green
                        : _isLoading
                            ? Colors.orange
                            : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isLoading
                      ? 'Loading'
                      : _isPlaying
                          ? 'Playing'
                          : 'Paused',
                  style: TextStyle(
                    color: widget.categoryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.categoryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Time display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDuration(_currentPosition),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: widget.categoryColor,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _totalDuration.inSeconds > 0
                        ? _formatDuration(_totalDuration)
                        : 'Loading...',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.withOpacity(0.2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          widget.categoryColor,
                          widget.categoryColor.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.categoryColor.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Progress percentage
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final percentage = (_progressAnimation.value * 100).round();
              return Text(
                '$percentage% Complete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showExitDialog();
        return false; // Prevent immediate pop, let dialog handle it
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.categoryColor.withOpacity(0.08),
                widget.categoryColor.withOpacity(0.04),
                Theme.of(context).colorScheme.surface,
              ],
              stops: const [0.0, 0.2, 1.0],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Modern Header
                  _buildModernHeader(),

                  // Content with better spacing
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Compact Session Info
                          _buildCompactSessionInfo(),

                          const SizedBox(height: 24),

                          // Main Visualization Circle (takes most space)
                          Expanded(child: _buildVisualization()),

                          const SizedBox(height: 20),

                          // Inline Progress
                          _buildInlineProgress(),

                          const SizedBox(height: 24),

                          // Compact Controls
                          _buildCompactControls(),

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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: widget.categoryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: widget.categoryColor.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with icon
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.categoryColor.withOpacity(0.2),
                      widget.categoryColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.headset,
                  color: widget.categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            fontSize: 20,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.categoryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.categoryColor.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            widget.duration,
                            style: TextStyle(
                              color: widget.categoryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'by ${widget.source}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.withOpacity(0.7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Description
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.categoryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.categoryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Text(
              widget.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.withOpacity(0.8),
                    height: 1.5,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualization() {
    if (_hasError) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Colors.red.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Audio Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow rings
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isPlaying ? _pulseAnimation.value * 0.3 + 1.0 : 1.0,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.categoryColor.withOpacity(0.0),
                          widget.categoryColor.withOpacity(0.05),
                          widget.categoryColor.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Middle ring
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isPlaying ? _pulseAnimation.value * 0.2 + 1.0 : 1.0,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.categoryColor.withOpacity(0.1),
                          widget.categoryColor.withOpacity(0.15),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Enhanced main circle with smooth transitions
            AnimatedBuilder(
              animation:
                  Listenable.merge([_pulseAnimation, _playPauseAnimation]),
              builder: (context, child) {
                final pulseScale =
                    _isPlaying ? _pulseAnimation.value * 0.1 + 1.0 : 1.0;
                final playPauseScale = _playPauseAnimation.value * 0.08 + 1.0;

                return Transform.scale(
                  scale: pulseScale * playPauseScale,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.categoryColor
                              .withOpacity(_isPlaying ? 0.35 : 0.25),
                          widget.categoryColor
                              .withOpacity(_isPlaying ? 0.25 : 0.18),
                          widget.categoryColor
                              .withOpacity(_isPlaying ? 0.15 : 0.10),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.categoryColor
                              .withOpacity(_isPlaying ? 0.4 : 0.2),
                          blurRadius: _isPlaying ? 50 : 30,
                          spreadRadius: 0,
                        ),
                        if (_isPlaying)
                          BoxShadow(
                            color: widget.categoryColor.withOpacity(0.2),
                            blurRadius: 80,
                            spreadRadius: 10,
                          ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.categoryColor
                              .withOpacity(_isPlaying ? 0.5 : 0.3),
                          width: _isPlaying ? 3 : 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Enhanced Play/Pause icon with animations
                          AnimatedBuilder(
                            animation: _playPauseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_playPauseAnimation.value * 0.15),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: widget.categoryColor
                                        .withOpacity(_isPlaying ? 0.3 : 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: widget.categoryColor
                                          .withOpacity(_isPlaying ? 0.4 : 0.3),
                                      width: _isPlaying ? 2 : 1,
                                    ),
                                    boxShadow: _isPlaying
                                        ? [
                                            BoxShadow(
                                              color: widget.categoryColor
                                                  .withOpacity(0.4),
                                              blurRadius: 15,
                                              spreadRadius: 0,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    widget.categoryColor),
                                          ),
                                        )
                                      : AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          transitionBuilder:
                                              (child, animation) {
                                            return ScaleTransition(
                                              scale: animation,
                                              child: FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: Icon(
                                            _isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            key: ValueKey(
                                                '${_isPlaying}_center_icon'),
                                            color: widget.categoryColor,
                                            size: 28,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Animated status text
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _isLoading
                                  ? 'Loading...'
                                  : _isPlaying
                                      ? 'Playing'
                                      : 'Paused',
                              key: ValueKey(
                                  '${_isLoading}_${_isPlaying}_center_status'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                    color: widget.categoryColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: widget.categoryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Skip backward
          _buildControlButton(
            icon: Icons.replay_5,
            onPressed: _isLoading ? null : _skipBackward,
            isSecondary: true,
            tooltip: 'Skip back 5s',
          ),

          const SizedBox(width: 20),

          // Play/Pause button
          _buildControlButton(
            icon: _isLoading
                ? null
                : _isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
            onPressed: _isLoading ? null : _togglePlayPause,
            isSecondary: false,
            isLoading: _isLoading,
            tooltip: _isPlaying ? 'Pause' : 'Play',
          ),

          const SizedBox(width: 20),

          // Skip forward
          _buildControlButton(
            icon: Icons.forward_5,
            onPressed: _isLoading ? null : _skipForward,
            isSecondary: true,
            tooltip: 'Skip forward 5s',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    IconData? icon,
    VoidCallback? onPressed,
    required bool isSecondary,
    bool isLoading = false,
    String? tooltip,
  }) {
    final isDisabled = onPressed == null;

    if (isSecondary) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDisabled
                ? Colors.grey.withOpacity(0.2)
                : widget.categoryColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Container(
              child: Icon(
                icon,
                size: 24,
                color: isDisabled
                    ? Colors.grey.withOpacity(0.4)
                    : widget.categoryColor,
              ),
            ),
          ),
        ),
      );
    } else {
      // Main play/pause button
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: isDisabled
              ? null
              : LinearGradient(
                  colors: [
                    widget.categoryColor,
                    widget.categoryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: isDisabled ? Colors.grey.withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: widget.categoryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onPressed,
            child: Container(
              child: isLoading
                  ? SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.9),
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                    ),
            ),
          ),
        ),
      );
    }
  }
}
