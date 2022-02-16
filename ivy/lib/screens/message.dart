import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final String postId = 'abc';
  bool inCall = false;
  List<dynamic> callUsers = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();

          callUsers = snapshot.data?.get('callUsers');
          return TextButton(
            onPressed: () async {
              if (inCall) {
                signaling.hangUp(postId);
                callUsers.remove(FirebaseAuth.instance.currentUser!.uid);
                FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .set({'callUsers': callUsers}, SetOptions(merge: true));
                setState(() {
                  inCall = false;
                });
              } else if (!inCall && callUsers.length < 5) {
                await signaling.openUserMedia();
                switch (callUsers.length) {
                  case 0:
                    await signaling.createOffer(postId, 'me');
                    break;
                  case 1:
                    await signaling.answerOffer(postId);
                    break;
                  default:
                }
                // for each person in call make a connection
                callUsers.add(FirebaseAuth.instance.currentUser!.uid);
                FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .set({'callUsers': callUsers}, SetOptions(merge: true));
                setState(() {
                  inCall = true;
                });
              }
            },
            child: Text(inCall.toString() + callUsers.length.toString()),
          );
        });
  }
}
