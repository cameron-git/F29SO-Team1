import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    Key? key,
    required this.videoURL,
    required this.playing,
    required this.isVideo,
    this.inDrawerList = false,
  }) : super(key: key);

  final String videoURL;
  final bool playing;
  final bool isVideo;
  final bool inDrawerList;

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    controller = VideoPlayerController.network(widget.videoURL);
    controller.addListener(() {
      setState(() {});
    });
    _initializeVideoPlayerFuture = controller.initialize();
    controller.setLooping(false);
    widget.inDrawerList ? controller.setVolume(0.0) : controller.setVolume(0.3);
    widget.playing ? play() : stop();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (widget.inDrawerList) {
            return FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                height: controller.value.size.height,
                width: controller.value.size.width,
                child: VideoPlayer(controller),
              ),
            );
          } else {
            return AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            );
          }
        } else {
          return widget.isVideo
              ? const Center(child: CircularProgressIndicator())
              : Container();
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> play() async {
    await controller.play();
  }

  Future<void> stop() async {
    await controller.pause();
    await controller.seekTo(Duration.zero);
  }
}
