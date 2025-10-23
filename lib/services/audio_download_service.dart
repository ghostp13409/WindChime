import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../config/audio_config.dart';

class AudioDownloadService {
  static final AudioDownloadService _instance =
      AudioDownloadService._internal();
  factory AudioDownloadService() => _instance;
  AudioDownloadService._internal();

  // Cache directory for downloaded audio files
  Directory? _cacheDir;

  // Initialize cache directory
  Future<void> initialize() async {
    if (_cacheDir == null) {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory(path.join(appDir.path, 'audio_cache'));
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
    }
  }

  // Check if audio file is already downloaded
  Future<bool> isDownloaded(String audioPath) async {
    await initialize();
    final fileName = AudioConfig.getLocalFileName(audioPath);
    if (fileName.isEmpty) return false;

    final file = File(path.join(_cacheDir!.path, fileName));
    return await file.exists();
  }

  // Get local file path for audio
  Future<String?> getLocalFilePath(String audioPath) async {
    await initialize();
    final fileName = AudioConfig.getLocalFileName(audioPath);
    if (fileName.isEmpty) return null;

    return path.join(_cacheDir!.path, fileName);
  }

  // Download audio file with progress callback
  Future<bool> downloadAudio(
    String audioPath, {
    Function(double progress)? onProgress,
    Function(String error)? onError,
  }) async {
    try {
      await initialize();

      final downloadUrl = AudioConfig.getDownloadUrl(audioPath);
      final fileName = AudioConfig.getLocalFileName(audioPath);

      if (downloadUrl.isEmpty || fileName.isEmpty) {
        final error = 'Invalid audio path: $audioPath';
        onError?.call(error);
        return false;
      }

      // Check if already downloaded
      if (await isDownloaded(audioPath)) {
        return true;
      }

      // Create HTTP client for streaming download
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(downloadUrl));
      request.headers['User-Agent'] = 'WindChime/1.0';

      // Send request and get streamed response
      final response = await client.send(request);

      if (response.statusCode != 200) {
        final error = 'Download failed: ${response.statusCode}';
        onError?.call(error);
        client.close();
        return false;
      }

      // Get content length for progress calculation
      final contentLength = response.contentLength ?? 0;
      int bytesReceived = 0;

      // Create file for writing
      final file = File(path.join(_cacheDir!.path, fileName));
      final sink = file.openWrite();

      // Listen to response stream
      await response.stream.listen(
        (chunk) {
          sink.add(chunk);
          bytesReceived += chunk.length;

          // Report progress if content length is known
          if (contentLength > 0 && onProgress != null) {
            final progress = bytesReceived / contentLength;
            onProgress(progress.clamp(0.0, 1.0));
          }
        },
        onDone: () async {
          await sink.close();
          client.close();

          // Report 100% completion if we have progress callback
          if (onProgress != null) {
            onProgress(1.0);
          }
        },
        onError: (error) {
          sink.close();
          client.close();
          onError?.call('Stream error: $error');
        },
        cancelOnError: true,
      ).asFuture();

      return true;
    } catch (e) {
      final error = 'Download error: $e';
      onError?.call(error);
      return false;
    }
  }

  // Download multiple audio files
  Future<Map<String, bool>> downloadMultipleAudio(
    List<String> audioPaths, {
    Function(double progress)? onProgress,
    Function(String error)? onError,
  }) async {
    final results = <String, bool>{};
    int completed = 0;

    for (final audioPath in audioPaths) {
      final success = await downloadAudio(
        audioPath,
        onError: onError,
      );
      results[audioPath] = success;
      completed++;

      if (onProgress != null) {
        onProgress(completed / audioPaths.length);
      }
    }

    return results;
  }

  // Clear all downloaded audio files
  Future<void> clearCache() async {
    await initialize();
    if (await _cacheDir!.exists()) {
      await _cacheDir!.delete(recursive: true);
      await _cacheDir!.create();
    }
  }

  // Get cache size
  Future<int> getCacheSize() async {
    await initialize();
    if (!await _cacheDir!.exists()) return 0;

    int totalSize = 0;
    await for (final file in _cacheDir!.list(recursive: true)) {
      if (file is File) {
        totalSize += await file.length();
      }
    }
    return totalSize;
  }

  // Get audio file path (bundled or downloaded)
  Future<String?> getAudioFilePath(String audioPath) async {
    // If it's a bundled file, return the asset path
    if (!AudioConfig.shouldDownload(audioPath)) {
      return 'assets/sounds/$audioPath';
    }

    // If it's a downloadable file, check if downloaded
    if (await isDownloaded(audioPath)) {
      return await getLocalFilePath(audioPath);
    }

    // Return null if not downloaded yet
    return null;
  }
}
