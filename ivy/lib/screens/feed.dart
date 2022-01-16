import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:ivy/widgets/progress.dart';

// referencing the Firestore instance
CollectionReference _usersRef = FirebaseFirestore.instance.collection('users');

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  void initState() {
    getUsers();
    super.initState();
  }

  getUsers() async {
    // get docs from collection reference
    QuerySnapshot snapshot = await _usersRef.get();

    // get data from docs and convert map to list
    final users = snapshot.docs.map((doc) => doc.data()).toList();

    // print whatevery is in users
    print(users);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('This is Feed.'),
    );
  }
}

class FeedItem extends StatelessWidget {
  const FeedItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('This is a feed item');
  }
}
