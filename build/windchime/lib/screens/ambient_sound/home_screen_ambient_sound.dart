import 'package:flutter/material.dart';
import 'package:prog2435_final_project_app/models/ambient_sound/sound.dart';
import 'package:prog2435_final_project_app/widgets/ambient_sound/sound_card.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:ui';
import 'package:flutter/services.dart'; // Import for haptics

class HomeScreenAmbientSound extends StatefulWidget {
  const HomeScreenAmbientSound({super.key});

  @override
  _HomeScreenAmbientSoundState createState() => _HomeScreenAmbientSoundState();
}

class _HomeScreenAmbientSoundState extends State<HomeScreenAmbientSound> {
  late AudioPlayer _audioPlayer;
  final ValueNotifier<Sound?> _currentPlayingSound =
      ValueNotifier<Sound?>(null);

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _currentPlayingSound.value = null;
      }
    });
  }

  final List<Sound> deepSleepSounds = [
    Sound(
      category: 'Deep Sleep',
      name: 'Deep Sleep',
      filePath: 'assets/sounds/ambient_sounds/deep-sleep.mp3',
      duration: const Duration(minutes: 10),
      isPlaying: false,
    ),
  ];

  final List<Sound> happyMusicSounds = [
    Sound(
      category: 'Happy Music',
      name: 'Happy Music',
      filePath: 'assets/sounds/ambient_sounds/happy-relaxing-loop.mp3',
      duration: const Duration(minutes: 5),
      isPlaying: false,
    ),
  ];

  final List<Sound> whiteNoiseSounds = [
    Sound(
      category: 'White Noise',
      name: 'White Noise',
      filePath: 'assets/sounds/ambient_sounds/fan-white-noise-heater.mp3',
      duration: const Duration(minutes: 15),
      isPlaying: false,
    ),
  ];

  final List<Sound> rainSounds = [
    Sound(
      category: 'Rain Sounds',
      name: 'Rain Sounds',
      filePath:
          'assets/sounds/ambient_sounds/rain-and-thunder-for-better-sleep.mp3',
      duration: const Duration(minutes: 20),
      isPlaying: false,
    ),
  ];

  Future<void> _playSound(String filePath, Sound sound) async {
    try {
      if (_currentPlayingSound.value == sound && _audioPlayer.playing) {
        _currentPlayingSound.value = null;
        await _audioPlayer.pause();
      } else {
        if (_audioPlayer.playing) {
          await _audioPlayer.stop();
        }
        _currentPlayingSound.value = sound;
        await _audioPlayer.setAsset(filePath);
        await _audioPlayer.play();
      }
    } catch (e) {
      _currentPlayingSound.value = null;
      debugPrint('Error playing sound: $e');
    }
  }

// commit
  @override
  void dispose() {
    _currentPlayingSound.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(String title, List<Sound> sounds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryHeader(title),
        SizedBox(
          height: 200,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: sounds.length,
            itemBuilder: (context, index) {
              final sound = sounds[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: 300,
                  child: ValueListenableBuilder<Sound?>(
                    valueListenable: _currentPlayingSound,
                    builder: (context, currentPlaying, _) {
                      return SoundCard(
                        sound: sound,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _playSound(sound.filePath, sound);
                        },
                        isPlaying: currentPlaying == sound,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2031),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              title: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Colors.white70],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: const Text(
                  'Ambient Sounds',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5',
                    fit: BoxFit.cover,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildCategoryList('Deep Sleep', deepSleepSounds),
                _buildCategoryList('Happy Music', happyMusicSounds),
                _buildCategoryList('White Noise', whiteNoiseSounds),
                _buildCategoryList('Rain Sounds', rainSounds),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
