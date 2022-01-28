// Should contain all post stuff and create new post widget
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewPost extends StatefulWidget {
  const NewPost({Key? key}) : super(key: key);

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  String title = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.green,
                    minimumSize: Size(5, 60)),
                onPressed: () =>
                    FirebaseFirestore.instance.collection('posts').add(
                  <String, dynamic>{
                    'timestamp': DateTime.now().millisecondsSinceEpoch,
                    'name': FirebaseAuth.instance.currentUser!.displayName,
                    'userId': FirebaseAuth.instance.currentUser!.uid,
                    'title': title,
                  },
                ),
                child: Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
