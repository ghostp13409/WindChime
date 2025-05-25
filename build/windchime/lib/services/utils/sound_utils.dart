import 'package:audioplayers/audioplayers.dart';

void playSound(String path) {
  AudioPlayer player = AudioPlayer();
  player.play(AssetSource(path));
}
