// Should contain all post stuff and create new post widget
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ivy/constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Random rand = Random();
final GlobalKey _canvasKey = GlobalKey();

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
  final TextEditingController _messageController = TextEditingController();
  final _scrollController = ScrollController();
  double aspectRatio = 1;

  void mediaPopUp() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Listener(
          onPointerSignal: (PointerSignalEvent event) {
            if (_scrollController.position.atEdge &&
                _scrollController.position.pixels == 0) {
              if (event is PointerScrollEvent && event.scrollDelta.dy < -10) {
                Navigator.of(context).pop();
              }
            }
          },
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (_scrollController.position.atEdge &&
                  _scrollController.position.pixels == 0) {
                if (details.primaryDelta! > 1) Navigator.of(context).pop();
              }
            },
            child: mediaList(),
          ),
        );
      },
    );
  }

// For Craig to implement
  Widget messageBoard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: primaryColour,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('messages')
                      .snapshots(),
                  builder: (context, snapshot) {
                    return ListView(
                      children: [],
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onSubmitted: (value) {
                        if (value.isNotEmpty) print(value.trimRight());
                      },
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            if (_messageController.text.isNotEmpty)
                              print(_messageController.text.trimRight());
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget liveCanvas() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          var squareSize = constraints
              .constrainSizeAndAttemptToPreserveAspectRatio(
                  const Size.square(2000))
              .shortestSide;
          return Center(
            child: Container(
              width: squareSize,
              height: squareSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: primaryColour,
                  width: 2,
                ),
              ),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('media')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return Stack(
                    key: _canvasKey,
                    children: snapshot.data!.docs.map(
                      (e) {
                        Widget img = Image.network(
                          e['url'],
                          width: squareSize * e['width'] / 100,
                          height: squareSize * e['height'] / 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                        return Positioned(
                          left: squareSize * e['left'] / 100,
                          top: squareSize * e['top'] / 100,
                          child: Draggable(
                            feedback: img,
                            child: img,
                            childWhenDragging: Container(),
                            onDragEnd: (dragDetails) {
                              final RenderBox renderBox =
                                  _canvasKey.currentContext?.findRenderObject()
                                      as RenderBox;
                              final Offset offset =
                                  renderBox.localToGlobal(Offset.zero);
                              final x = (dragDetails.offset.dx - offset.dx) /
                                  squareSize *
                                  100;
                              final y = (dragDetails.offset.dy - offset.dy) /
                                  squareSize *
                                  100;
                              FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(widget.postId)
                                  .collection('media')
                                  .doc(e.id)
                                  .update(
                                {
                                  'left': x,
                                  'top': y,
                                },
                              );
                            },
                          ),
                        );
                      },
                    ).toList(),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget mediaList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('media')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        List<Widget> items = {
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 100,
              child: Material(
                color: const Color.fromRGBO(127, 127, 127, 0.1),
                child: InkWell(
                  hoverColor: const Color.fromRGBO(127, 127, 127, 0.2),
                  onTap: () async {
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
                          .ref('images/${widget.postId}/$fileName')
                          .putData(bytes);
                      final url = await FirebaseStorage.instance
                          .ref('images/${widget.postId}/$fileName')
                          .getDownloadURL();
                      FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.postId)
                          .collection('media')
                          .add(
                        {
                          'url': url,
                          'left': 0,
                          'top': 0,
                          'width': 20,
                          'height': 20,
                        },
                      );
                    } else {
                      final path = results!.files.single.path!;
                      final fileName = results.files.single.name;
                      await FirebaseStorage.instance
                          .ref('images/${widget.postId}/$fileName')
                          .putFile(File(path));
                      final url = await FirebaseStorage.instance
                          .ref('images/${widget.postId}/$fileName')
                          .getDownloadURL();
                      FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.postId)
                          .collection('media')
                          .add(
                        {
                          'url': url,
                          'left': 0,
                          'top': 0,
                          'width': 20,
                          'height': 20,
                        },
                      );
                    }
                  },
                  child: const SizedBox(
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),
        }.toList();
        items += snapshot.data!.docs.map(
          (e) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                e['url'],
                width: 200,
                height: 100,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            );
          },
        ).toList();
        return ListView(
          controller: _scrollController,
          children: items,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final postId = widget.postId;
    final Stream<DocumentSnapshot> _postStream =
        FirebaseFirestore.instance.collection('posts').doc(postId).snapshots();

    aspectRatio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return StreamBuilder<DocumentSnapshot>(
      stream: _postStream,
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data?.data() == null) {
          return Container();
        }
        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> tags = data['tags'];
        List<dynamic> userPermissions = data['userPermissions'];
        _tagsController.text = tags.join(' ') + ' ';
        _titleController.text = data['title'];
        _descController.text = data['description'];

        bool perms =
            userPermissions.contains(FirebaseAuth.instance.currentUser?.uid);

        return Listener(
          onPointerSignal: (PointerSignalEvent event) {
            if (event is PointerScrollEvent &&
                event.scrollDelta.dy > 10 &&
                aspectRatio < 1.2) {
              mediaPopUp();
            }
          },
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < -1 && aspectRatio < 1.2) {
                mediaPopUp();
              }
            },
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              key: _scaffoldKey,
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: Text(
                  data['title'],
                ),
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
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              controller: _titleController,
                                              decoration: const InputDecoration(
                                                labelText: 'Title',
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              controller: _descController,
                                              decoration: const InputDecoration(
                                                labelText: 'Description',
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              controller: _tagsController,
                                              decoration: const InputDecoration(
                                                labelText: 'Tags',
                                              ),
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
                                            'tags': _tagsController.text
                                                .toUpperCase()
                                                .trim()
                                                .split(" "),
                                          },
                                          SetOptions(merge: true),
                                        );
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
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
              // endDrawer: Drawer(
              //   child: mediaList(postId),
              // ),
              endDrawerEnableOpenDragGesture: !kIsWeb,

              // top part of the post page containing the author and description
              body: Column(
                children: [
                  SizedBox(
                    height: (aspectRatio > 1.2)
                        ? MediaQuery.of(context).size.height - 56
                        : MediaQuery.of(context).size.height - 140,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (aspectRatio > 1.2)
                          Expanded(
                            child: messageBoard(),
                          ),
                        Expanded(
                          child: liveCanvas(),
                          flex: 2,
                        ),
                        if (aspectRatio > 1.2)
                          Expanded(
                            child: mediaList(),
                          )
                      ],
                    ),
                  ),
                  if (aspectRatio < 1.2)
                    Expanded(
                      child: Container(),
                    ),
                  if (aspectRatio < 1.2)
                    IconButton(
                      onPressed: () {
                        mediaPopUp();
                      },
                      icon: const Icon(
                        Icons.arrow_drop_up,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );

        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     FutureBuilder(
        //       future: FirebaseFirestore.instance
        //           .collection('users')
        //           .doc(data['ownerId'])
        //           .get(),
        //       builder: (BuildContext context,
        //           AsyncSnapshot<DocumentSnapshot> snapshot) {
        //         if (snapshot.hasError ||
        //             (snapshot.hasData && !snapshot.data!.exists)) {
        //           return const Text('Post Owner Error!!!');
        //         }
        //         if (snapshot.connectionState == ConnectionState.done) {
        //           Map<String, dynamic> data =
        //               snapshot.data!.data() as Map<String, dynamic>;
        //           return Text('Post Owner: ${data['name']}');
        //         }

        //         return const Text('Post Owner:');
        //       },
        //     ),
        //     Text('Time Posted : ' +
        //         DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
        //             .toString()
        //             .substring(0, 16)),
        //     Text('Description : ' + data['description']),
        //     Row(
        //       children: <Widget>[
        //         const Text('tags: '),
        //         for (var item in tags) Text(item + ' '),
        //       ],
        //     ),
        //   ],
        // ),
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
                      'tags':
                          _tagController.text.toUpperCase().trim().split(' '),
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
