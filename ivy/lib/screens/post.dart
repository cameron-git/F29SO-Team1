// Should contain all post stuff and create new post widget
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewPost extends StatelessWidget {
  const NewPost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            FirebaseFirestore.instance.collection('posts').add(
              <String, dynamic>{
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'name': FirebaseAuth.instance.currentUser!.displayName,
                'userId': FirebaseAuth.instance.currentUser!.uid,
              },
            );
          },
          child: const Text('Post'),
        ),
      ),
    );
  }
}
