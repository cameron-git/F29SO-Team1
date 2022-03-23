import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

class AudioPlayerWrapper {
  AudioPlayerWrapper(this.urlList) {
    _audioPlayers = List<AudioPlayer>.filled(urlList.length, AudioPlayer());
    for (var i = 0; i < urlList.length; i++) {
      _audioPlayers.elementAt(i).setUrl(urlList.elementAt(i));
    }
  }
  final List<String> urlList;
  late List<AudioPlayer> _audioPlayers;

  play() {
    for (var audioPlayer in _audioPlayers) {
      debugPrint('play audio');
      audioPlayer.resume();
    }
  }

  stop() {
    for (var audioPlayer in _audioPlayers) {
      audioPlayer.stop();
    }
  }
}
