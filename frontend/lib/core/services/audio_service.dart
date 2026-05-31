import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService() : _player = AudioPlayer();

  final AudioPlayer _player;
  bool _playing = false;

  bool get isPlaying => _playing;

  Future<void> playCalmAmbience() async {
    try {
      await _player.play(AssetSource('audio/calm.mp3'));
      _playing = true;
    } catch (_) {
      // Asset optional — add assets/audio/calm.mp3 for production
      _playing = false;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _playing = false;
  }

  Future<void> dispose() => _player.dispose();
}
