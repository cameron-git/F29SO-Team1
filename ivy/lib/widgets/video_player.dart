import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatefulWidget {
  String videoURL;

  VideoPlayerWidget({
    Key? key,
    this.videoURL = "",
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoURL);
    _controller.addListener(() {
      setState(() {});
    }); // TODO: What does this do?
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(1);
<<<<<<< HEAD
    super.initState();
=======
>>>>>>> 076ea67c859bc24879e5b2fb0ba83045294dfbb4
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return VideoPlayer(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
