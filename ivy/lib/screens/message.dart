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
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

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
    return Column(
      children: [
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            signaling.openUserMedia(_localRenderer, _remoteRenderer);
          },
          child: Text("Open camera & microphone"),
        ),
        SizedBox(
          width: 8,
        ),
        ElevatedButton(
          onPressed: () async {
            signaling.createOffer('abc');
          },
          child: Text("Create room"),
        ),
        SizedBox(
          width: 8,
        ),
        ElevatedButton(
          onPressed: () {
            // Add roomId
            signaling.answerOffer(
              'abc',
              _remoteRenderer,
            );
          },
          child: Text("Join room"),
        ),
        SizedBox(
          width: 8,
        ),
        ElevatedButton(
          onPressed: () {
            signaling.hangUp(_localRenderer);
          },
          child: Text("Hangup"),
        ),
      ],
    );
  }
}
