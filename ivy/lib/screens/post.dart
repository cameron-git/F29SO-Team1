// Should contain all post stuff and create new post widget
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ivy/storage_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

    // Storage instance from storage_service.dart
    final Storage storage = Storage();

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
        List<dynamic> userPermissions = data['userPermissions'];
        _tagsController.text = "";
        for (var tag in tags) {
          _tagsController.text += tag + " ";
        }
        _titleController.text = data['title'];
        _descController.text = data['description'];

        bool perms =
            userPermissions.contains(FirebaseAuth.instance.currentUser?.uid);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              data['title'],
            ),
            bottomOpacity: 0.0,
            elevation: 0.0,
            actions: [
              // edit button
              (perms)
                  ? IconButton(
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
                                          'tags':
                                              _tagsController.text.split(" "),
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
                    )
                  : const SizedBox(),
              // delete button
              (data['ownerId'] == FirebaseAuth.instance.currentUser?.uid)
                  ? IconButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('posts')
                            .doc(postId)
                            .delete();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete),
                    )
                  : const SizedBox(),
            ],
          ),

          // top part of the post page containing the author and description

          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(data['ownerId'])
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError ||
                      (snapshot.hasData && !snapshot.data!.exists)) {
                    return const Text('Post Owner Error!!!');
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Text('Post Owner: ${data['name']}');
                  }

                  return const Text('Post Owner:');
                },
              ),
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
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .collection('media')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return Expanded(
                    child: ListView(
                        children: snapshot.data!.docs.map(
                      (e) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 300,
                            height: 250,
                            child: Image.network(
                              e['url'],
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ).toList()),
                  );
                },
              ),
            ],
          ),

          // floating button to add new media to the post
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              final results = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                type: FileType.custom,
                allowedExtensions: ['png', 'jpg'],
              );

              if (results == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No file selected.'),
                  ),
                );
              }
              if (kIsWeb) {
                final bytes = results!.files.single.bytes!;
                final fileName = results.files.single.name;
                await FirebaseStorage.instance
                    .ref('images/$postId/$fileName')
                    .putData(bytes);
                final url = await FirebaseStorage.instance
                    .ref('images/$postId/$fileName')
                    .getDownloadURL();
                FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .collection('media')
                    .add({'url': url});
              } else {
                final path = results!.files.single.path!;
                final fileName = results.files.single.name;
                await FirebaseStorage.instance
                    .ref('images/$postId/$fileName')
                    .putFile(File(path));
                final url = await FirebaseStorage.instance
                    .ref('images/$postId/$fileName')
                    .getDownloadURL();
                FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .collection('media')
                    .add({'url': url});
              }
            },
            foregroundColor: Colors.white,
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
