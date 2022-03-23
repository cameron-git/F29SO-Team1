import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class VoiceCallButton extends StatefulWidget {
  const VoiceCallButton({Key? key}) : super(key: key);

  @override
  State<VoiceCallButton> createState() => _VoiceCallButtonState();
}

class _VoiceCallButtonState extends State<VoiceCallButton> {
  late bool inCall;
  @override
  void initState() {
    inCall = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          inCall = !inCall;
        });
      },
      icon: inCall
          ? VoiceCallIcon()
          : const Icon(
              Icons.call,
            ),
    );
  }
}

class VoiceCallIcon extends StatefulWidget {
  @override
  State<VoiceCallIcon> createState() => _VoiceCallIconState();
}

class _VoiceCallIconState extends State<VoiceCallIcon> {
  final roomId = '0000';
  final config = {
    'iceServers': [
      {"url": "stun:stun.l.google.com:19302"},
    ]
  };

  final sdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': false,
    },
    'optional': []
  };
  late final IO.Socket socket;
  final _localRenderer = RTCVideoRenderer();
  List<RTCVideoRenderer> _remoteRenderers = <RTCVideoRenderer>[];
  MediaStream? _localStream;
  List<RTCPeerConnection?>? pc = <RTCPeerConnection>[];
  @override
  void dispose() {
    for (var item in _remoteRenderers) {
      item.dispose();
    }
    for (var item in pc!) {
      item?.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  Future init() async {
    await _localRenderer.initialize();

    await connectSocket();
    await joinRoom();
  }

  Future connectSocket() async {
    socket = IO.io(
      'http://localhost:3000',
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );
    socket.onConnect((data) => print('Connected to socket'));

    socket.on('joined', (data) {
      debugPrint('Someone joined');
      _sendOffer();
    });

    socket.on('offer', (data) async {
      data = jsonDecode(data);
      await _gotOffer(RTCSessionDescription(data['sdp'], data['type']));
      await _sendAnswer();
    });

    socket.on('answer', (data) {
      data = jsonDecode(data);
      _gotAnswer(RTCSessionDescription(data['sdp'], data['type']));
    });

    socket.on('ice', (data) {
      data = jsonDecode(data);
      _gotIce(RTCIceCandidate(
          data['candidate'], data['sdpMid'], data['sdpMLineIndex']));
    });
  }

  Future joinRoom() async {
    debugPrint('joinRoom func');
    // pc?.add(await createPeerConnection(config, sdpConstraints));

    final mediaConstraints = {
      'audio': true,
      'video': false,
    };

    _localStream = await Helper.openCamera(mediaConstraints);

    _localRenderer.srcObject = _localStream;

    debugPrint('emit join');
    socket.emit('join');
  }

  Future _sendOffer() async {
    debugPrint('send offer');

    pc?.add(await createPeerConnection(config, sdpConstraints));
    _localStream!.getTracks().forEach((track) {
      pc!.last!.addTrack(track, _localStream!);
    });

    pc!.last!.onIceCandidate = (ice) {
      _sendIce(ice);
    };

    pc!.last!.onAddStream = (stream) async {
      _remoteRenderers.add(RTCVideoRenderer());
      await _remoteRenderers.last.initialize();
      _remoteRenderers.last.srcObject = stream;
    };

    var offer = await pc!.last!.createOffer();
    pc!.last!.setLocalDescription(offer);
    socket.emit(
      'offer',
      jsonEncode(offer.toMap()),
    );
  }

  Future _gotOffer(RTCSessionDescription offer) async {
    debugPrint('got offer');

    pc?.add(await createPeerConnection(config, sdpConstraints));
    _localStream!.getTracks().forEach((track) {
      pc!.last!.addTrack(track, _localStream!);
    });

    pc!.last!.onIceCandidate = (ice) {
      _sendIce(ice);
    };

    pc!.last!.onAddStream = (stream) async {
      _remoteRenderers.add(RTCVideoRenderer());
      await _remoteRenderers.last.initialize();
      _remoteRenderers.last.srcObject = stream;
    };

    pc!.last!.setRemoteDescription(offer);
  }

  Future _sendAnswer() async {
    print('send answer');
    var answer = await pc!.last!.createAnswer();
    pc!.last!.setLocalDescription(answer);
    socket.emit(
      'answer',
      jsonEncode(answer.toMap()),
    );
  }

  Future _gotAnswer(RTCSessionDescription answer) async {
    print('got answer');
    pc!.last!.setRemoteDescription(answer);
  }

  Future _sendIce(RTCIceCandidate ice) async {
    debugPrint('send ice');
    socket.emit(
      'ice',
      jsonEncode(ice.toMap()),
    );
  }

  Future _gotIce(RTCIceCandidate ice) async {
    debugPrint('got ice');
    pc!.last!.addCandidate(ice);
  }

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.call_end);
  }
}
