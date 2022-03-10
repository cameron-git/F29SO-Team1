// New comment
// Should contain all post stuff and create new post widget
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ivy/constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ivy/widgets/video_player.dart';

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

  double aspectRatio = 1; // to get the aspect ratio of the screen

  // drawer pop up to select the media on the post
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
            child: mediaList(), // display the media list in the the drawer
          ),
        );
      },
    );
  }

  // widget for the message board on a certain post
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
                // Selects location in firebase storage
                // posts\post\messages
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return ListView(
                    reverse: true,
                    children: snapshot.data!.docs.map(
                      (e) {
                        return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(e['uid'])
                              .get(),
                          builder: (context,
                              AsyncSnapshot<
                                      DocumentSnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (!snapshot.hasData) return Container();
                            Duration d = DateTime.now().difference(
                                DateTime.fromMillisecondsSinceEpoch(
                                    e['timestamp']));

                            String ago = '';
                            if (d.inMinutes == 0) {
                              ago = 'just now';
                            } else if (d.inMinutes < 60) {
                              ago = d.inMinutes.toString();
                              ago += (d.inMinutes == 1)
                                  ? ' minute ago'
                                  : ' minutes ago';
                            } else if (d.inHours < 24) {
                              ago = d.inHours.toString();
                              ago +=
                                  (d.inHours == 1) ? ' hour ago' : ' hours ago';
                            } else if (d.inDays < 365) {
                              ago = d.inDays.toString();
                              ago += (d.inDays == 1) ? ' day ago' : ' days ago';
                            } else {
                              ago = (d.inDays / 365).floor().toString();
                              ago += ((d.inDays / 365).floor() == 1)
                                  ? ' year ago'
                                  : ' years ago';
                            }
                            bool myPost = e['uid'] ==
                                FirebaseAuth.instance.currentUser?.uid;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: myPost
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          myPost
                                              ? 'Me: ${e['message']}'
                                              : '${snapshot.data!.get('name')}: ${e['message']}',
                                          style: TextStyle(
                                              color:
                                                  myPost ? Colors.black : null),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          ago,
                                          style: TextStyle(
                                              color: myPost
                                                  ? Colors.black54
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onBackground),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ).toList(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      maxLength: 512,
                      onSubmitted: (value) {
                        if (_messageController.text == '') return;
                        FirebaseFirestore.instance
                            .collection('posts')
                            .doc(widget.postId)
                            .collection('messages')
                            .add(
                          {
                            'timestamp': DateTime.now().millisecondsSinceEpoch,
                            'uid': FirebaseAuth.instance.currentUser!.uid,
                            'message': _messageController.text.trimRight(),
                          },
                        );
                        _messageController.clear();
                      },
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            if (_messageController.text == '') return;
                            FirebaseFirestore.instance
                                .collection('posts')
                                .doc(widget.postId)
                                .collection('messages')
                                .add(
                              {
                                'timestamp':
                                    DateTime.now().millisecondsSinceEpoch,
                                'uid': FirebaseAuth.instance.currentUser!.uid,
                                'message': _messageController.text.trimRight(),
                              },
                            );
                            _messageController.clear();
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

  // widget holding the canvas
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
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Stack(
                    key: _canvasKey,
                    children: snapshot.data!.docs.map(
                      (e) {
                        Widget media;

                        if (e['type'] == "videos") {
                          debugPrint("It's a video");
                          // media = VideoPlayerWidget(videoURL: e['url']);
                          // have a blue container for debugging for now
                          media = Container(
                            height: 100,
                            width: 100,
                            color: Colors.blue,
                          );
                        } else if (e['type'] == "audio") {
                          debugPrint("It's an audio file");
                          media = Container(
                            height: 100,
                            width: 100,
                            color: Colors.green,
                          );
                        } else {
                          media = CachedNetworkImage(
                            imageUrl: e['url'],
                            width: squareSize * e['width'] / 100,
                            height: squareSize * e['height'] / 100,
                            fit: BoxFit.cover,
                          );
                        }

                        return Positioned(
                          left: squareSize * e['left'] / 100,
                          top: squareSize * e['top'] / 100,
                          // ability to drag the media
                          child: Draggable(
                            feedback: media,
                            child: media,
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
                              // update storage with position
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

  // widget containing all the media in a post
  Widget mediaList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('media')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // return loading circle while the images are loading
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        // list of all the items displayed in the media list
        List<Widget> items = {
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 100,
              child: Material(
                color: const Color.fromRGBO(127, 127, 127, 0.1),
                // button with + sign
                child: InkWell(
                  hoverColor: const Color.fromRGBO(127, 127, 127, 0.2),
                  // when you tap on it, open local phone file storage
                  onTap: () async {
                    final results = await FilePicker.platform.pickFiles(
                      allowMultiple: false,
                      type: FileType.custom,
                      allowedExtensions: ['png', 'jpg', 'mp4', 'mp3'],
                    );
                    // if no file was chosen, tell the user
                    if (results == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No file selected.'),
                        ),
                      );
                    }
                    // if the app is running on the web
                    if (kIsWeb) {
                      final bytes =
                          results!.files.single.bytes!; // get the selected file
                      final fileName = results.files.single
                          .name; // get the name of the selected file
                      var type = results.files.single.extension;

                      // upload the image to firebase storage
                      String folder;
                      if (type == "jpg" || type == "png") {
                        folder = "images";
                      } else if (type == "mp4") {
                        folder = "videos";
                      } else if (type == "mp3") {
                        folder = "audio";
                      } else {
                        folder = "default";
                      }

                      // upload the image to firebase storage
                      await FirebaseStorage.instance
                          .ref('$folder/${widget.postId}/$fileName')
                          .putData(bytes);
                      final url = await FirebaseStorage.instance
                          .ref('$folder/${widget.postId}/$fileName')
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
                          'type': folder,
                        },
                      );
                      // if the app is hosted on a mobile device
                    } else {
                      final path = results!.files.single.path!;
                      final fileName = results.files.single.name;
                      var type = results.files.single.extension;

                      // upload the image to firebase storage
                      String folder;
                      if (type == "jpg" || type == "png") {
                        folder = "images";
                      } else if (type == "mp4") {
                        folder = "videos";
                      } else if (type == "mp3") {
                        folder = "audio";
                      } else {
                        folder = "default";
                      }

                      await FirebaseStorage.instance
                          .ref('$folder/${widget.postId}/$fileName')
                          .putFile(File(path));
                      final url = await FirebaseStorage.instance
                          .ref('$folder/${widget.postId}/$fileName')
                          .getDownloadURL();
                      // adding media to the post instance
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
                          'type': folder,
                        },
                      );
                    }
                  },
                  // add-button to add more media
                  child: const SizedBox(
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),
        }.toList(); // put all the items into a list and display below the add button

        items += snapshot.data!.docs.map(
          (e) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 100,
                width: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          displayMediaType(e),
                          Container(
                              color: Theme.of(context).colorScheme.background,
                              child: const Icon(Icons.image)),
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.download)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                  ],
                ),
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

  displayMediaType(QueryDocumentSnapshot media) {
    var mediaType = media['type'];
    debugPrint("This is the type: " + mediaType);

    if (mediaType == "images") {
      return CachedNetworkImage(
        imageUrl: media['url'],
        width: 500,
        fit: BoxFit.cover,
      );
    } else if (mediaType == "audio") {
      return Container(
        height: 200,
        width: 50,
        color: Colors.green,
      );
    } else if (mediaType == "videos") {
      return Container(
        height: 200,
        width: 50,
        color: Colors.blue,
      );
    }
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

        // listener for media pop-up
        return Listener(
          // on scroll-up open up the media pop-up
          onPointerSignal: (PointerSignalEvent event) {
            if (event is PointerScrollEvent &&
                event.scrollDelta.dy > 10 &&
                aspectRatio < 1.2) {
              mediaPopUp();
            }
          },
          // on swipe-up open up the media pop-up
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
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.play_arrow)),
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
                        ? MediaQuery.of(context).size.height - 68
                        : MediaQuery.of(context).size.height -
                            167, // TODO: these two cannot be hard-coded
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
