import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:ivy/signaling.dart';

Map<String, dynamic> servers = {
  'iceServers': [
    {
      'urls': ['stun:stun1.l.google.com:19302', 'stun:stun2.l.google.com:19302']
    }
  ]
};

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final String postId = 'abc';
  bool inCall = false;

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        if (inCall) {
          signaling.hangUp(postId, _localRenderer);
          setState(() {
            inCall = false;
          });
        } else {
          await signaling.openUserMedia(_localRenderer, _remoteRenderer);
          // for each person in call make a connection
          setState(() {
            inCall = true;
          });
        }
      },
      child: Text(inCall.toString()),
    );
  }
}
