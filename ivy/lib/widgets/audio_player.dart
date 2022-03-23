import 'package:flutter/material.dart';

class AudioPlayer extends StatefulWidget {
  const AudioPlayer(this.urlList, {Key? key}) : super(key: key);
  final List<String> urlList;

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
