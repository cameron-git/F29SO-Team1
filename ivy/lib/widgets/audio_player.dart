import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({required this.url, required this.playing, Key? key})
      : super(key: key);
  final String url;
  final bool playing;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final FlutterSoundPlayer audioPlayer = FlutterSoundPlayer();

  @override
  void initState() {
    helper();
    super.initState();
  }

  helper() async {
    await audioPlayer.openPlayer();
    widget.playing
        ? await audioPlayer.startPlayer(fromURI: widget.url, codec: Codec.mp3)
        : await audioPlayer.stopPlayer();
  }

  @override
  void dispose() {
    audioPlayer.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
