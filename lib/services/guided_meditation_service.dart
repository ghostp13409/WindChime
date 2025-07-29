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
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:windchime/models/meditation/guided_meditation.dart';
import 'package:windchime/models/meditation/session_history.dart';
import 'package:windchime/data/repositories/meditation_repository.dart';
import 'package:windchime/services/audio_download_service.dart';

enum PlaybackState {
  stopped,
  playing,
  paused,
  loading,
  completed,
  error,
}

class GuidedMeditationService extends ChangeNotifier {
  static final GuidedMeditationService _instance =
      GuidedMeditationService._internal();
  factory GuidedMeditationService() => _instance;
  GuidedMeditationService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final MeditationRepository _meditationRepository = MeditationRepository();

  // Current session state
  GuidedMeditation? _currentMeditation;
  PlaybackState _playbackState = PlaybackState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  DateTime? _sessionStartTime;
  bool _isInitialized = false;

  // Getters
  GuidedMeditation? get currentMeditation => _currentMeditation;
  PlaybackState get playbackState => _playbackState;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _playbackState == PlaybackState.playing;
  bool get isPaused => _playbackState == PlaybackState.paused;
  bool get isLoading => _playbackState == PlaybackState.loading;
  bool get hasAudio => _currentMeditation != null;

  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  String get formattedPosition {
    return _formatDuration(_position);
  }

  String get formattedDuration {
    return _formatDuration(_duration);
  }

  String get formattedRemaining {
    final remaining = _duration - _position;
    return _formatDuration(remaining);
  }

  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      switch (playerState.processingState) {
        case ProcessingState.idle:
          _updatePlaybackState(PlaybackState.stopped);
          break;
        case ProcessingState.loading:
          _updatePlaybackState(PlaybackState.loading);
          break;
        case ProcessingState.buffering:
          _updatePlaybackState(PlaybackState.loading);
          break;
        case ProcessingState.ready:
          if (playerState.playing) {
            _updatePlaybackState(PlaybackState.playing);
          } else {
            _updatePlaybackState(PlaybackState.paused);
          }
          break;
        case ProcessingState.completed:
          _updatePlaybackState(PlaybackState.completed);
          _onSessionCompleted();
          break;
      }
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    _isInitialized = true;
  }

  // Load and prepare a meditation for playback
  Future<void> loadMeditation(GuidedMeditation meditation) async {
    try {
      await initialize();

      _currentMeditation = meditation;
      _updatePlaybackState(PlaybackState.loading);

      // Get the audio file path (bundled or downloaded)
      final audioDownloadService = AudioDownloadService();
      final audioFilePath =
          await audioDownloadService.getAudioFilePath(meditation.audioPath);

      if (audioFilePath == null) {
        // File not downloaded yet, try to download it
        final success = await audioDownloadService.downloadAudio(
          meditation.audioPath,
          onError: (error) {
            debugPrint('Download error: $error');
          },
        );

        if (success) {
          // Try to get the path again after download
          final downloadedPath =
              await audioDownloadService.getAudioFilePath(meditation.audioPath);
          if (downloadedPath != null) {
            await _audioPlayer.setFilePath(downloadedPath);
          } else {
            throw Exception('Failed to get downloaded file path');
          }
        } else {
          throw Exception('Failed to download audio file');
        }
      } else {
        // File is available (bundled or downloaded)
        if (audioFilePath.startsWith('assets/')) {
          // Bundled file
          await _audioPlayer.setAsset(audioFilePath);
        } else {
          // Downloaded file
          await _audioPlayer.setFilePath(audioFilePath);
        }
      }

      _updatePlaybackState(PlaybackState.paused);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading meditation: $e');
      _updatePlaybackState(PlaybackState.error);
    }
  }

  // Start playback
  Future<void> play() async {
    if (_currentMeditation == null) return;

    try {
      // Record session start time if this is a new session
      _sessionStartTime ??= DateTime.now();

      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing meditation: $e');
      _updatePlaybackState(PlaybackState.error);
    }
  }

  // Pause playback
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('Error pausing meditation: $e');
    }
  }

  // Stop playback and save session
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      await _saveCurrentSession();
      _resetSession();
    } catch (e) {
      debugPrint('Error stopping meditation: $e');
    }
  }

  // Seek to specific position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  // Skip forward by specified duration
  Future<void> skipForward(Duration duration) async {
    final newPosition = _position + duration;
    if (newPosition < _duration) {
      await seek(newPosition);
    }
  }

  // Skip backward by specified duration
  Future<void> skipBackward(Duration duration) async {
    final newPosition = _position - duration;
    if (newPosition > Duration.zero) {
      await seek(newPosition);
    } else {
      await seek(Duration.zero);
    }
  }

  // Set playback speed
  Future<void> setSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed);
    } catch (e) {
      debugPrint('Error setting speed: $e');
    }
  }

  // Private methods
  void _updatePlaybackState(PlaybackState state) {
    _playbackState = state;
    notifyListeners();
  }

  Future<void> _onSessionCompleted() async {
    await _saveCurrentSession();
    _resetSession();
  }

  Future<void> _saveCurrentSession() async {
    if (_currentMeditation == null || _sessionStartTime == null) return;

    final sessionDuration = _position.inSeconds;
    if (sessionDuration < 10) return; // Don't save very short sessions

    final session = SessionHistory(
      date: _sessionStartTime!,
      duration: sessionDuration,
      meditationType: 'guided_${_currentMeditation!.categoryId}',
    );

    try {
      await _meditationRepository.addSession(session);
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  void _resetSession() {
    _currentMeditation = null;
    _sessionStartTime = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Dispose resources
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Additional utility methods

  // Get playback progress as percentage (0-100)
  int get progressPercentage {
    return (progress * 100).round();
  }

  // Check if we're near the end of the meditation
  bool get isNearEnd {
    final remaining = _duration - _position;
    return remaining.inSeconds < 30; // Less than 30 seconds remaining
  }

  // Get time remaining in seconds
  int get remainingSeconds {
    return (_duration - _position).inSeconds;
  }

  // Check if the user has listened to at least 50% of the meditation
  bool get hasSignificantProgress {
    return progress >= 0.5;
  }

  // Reset to beginning
  Future<void> restart() async {
    await seek(Duration.zero);
    if (_playbackState == PlaybackState.completed) {
      _updatePlaybackState(PlaybackState.paused);
    }
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }
}
