// Should contain all post stuff and create new post widget

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  const Post(this.postId, {Key? key}) : super(key: key);
  final String postId;

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final postId = widget.postId;
    final Stream<DocumentSnapshot> _postStream =
        FirebaseFirestore.instance.collection('posts').doc(postId).snapshots();
    return StreamBuilder<DocumentSnapshot>(
      stream: _postStream,
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> tags = data['tags'];
        _tagsController.text = "";
        for (var tag in tags) {
          _tagsController.text += tag + " ";
        }
        _titleController.text = data['title'];
        _descController.text = data['description'];
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text(
                  data['title'],
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            scrollable: true,
                            title: const Text('Edit Post Info'),
                            content: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Form(
                                child: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      controller: _titleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Title',
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _descController,
                                      decoration: const InputDecoration(
                                        labelText: 'Description',
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _tagsController,
                                      decoration: const InputDecoration(
                                        labelText: 'Tags',
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                child: const Text("Submit"),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(postId)
                                      .set(
                                    <String, dynamic>{
                                      'title': _titleController.text,
                                      'description': _descController.text,
                                      'tags': _tagsController.text.split(" "),
                                    },
                                    SetOptions(merge: true),
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  },
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .delete();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete),
              )
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Post Owner ID : ' + data['ownerId']),
              Text('Time Posted : ' +
                  DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
                      .toString()
                      .substring(0, 16)),
              Text('Description : ' + data['description']),
              Row(
                children: <Widget>[
                  const Text('tags: '),
                  for (var item in tags) Text(item + ' '),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class NewPost extends StatefulWidget {
  const NewPost({Key? key}) : super(key: key);

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Tags (space separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  minimumSize: const Size(5, 60),
                ),
                onPressed: () {
                  FirebaseFirestore.instance.collection('posts').add(
                    <String, dynamic>{
                      'timestamp': DateTime.now().millisecondsSinceEpoch,
                      'ownerId': FirebaseAuth.instance.currentUser!.uid,
                      'userPermissions': [
                        FirebaseAuth.instance.currentUser!.uid
                      ],
                      'title': _titleController.text,
                      'description': _descController.text,
                      'tags': _tagController.text.split(' '),
                    },
                  );
                  Navigator.pop(context);
                },
                child: const Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
