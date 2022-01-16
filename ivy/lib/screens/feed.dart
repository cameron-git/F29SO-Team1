import 'package:flutter/material.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    return Text('This is the Feed.');
  }
}

class FeedItem extends StatelessWidget {
  const FeedItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('This is a feed item');
  }
}
