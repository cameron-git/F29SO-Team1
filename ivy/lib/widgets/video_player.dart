import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoURL;

  VideoPlayerWidget({
    Key? key,
    this.videoURL = "",
  }) : super(key: key);

  VideoPlayerWidgetState videoState = VideoPlayerWidgetState();

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.network(widget.videoURL);
    controller.addListener(() {
      setState(() {});
    });
    _initializeVideoPlayerFuture = controller.initialize();
    controller.setLooping(true);
    controller.setVolume(1);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void play() {
    controller.play();
  }

  void pause() {
    controller.pause();
  }
}
