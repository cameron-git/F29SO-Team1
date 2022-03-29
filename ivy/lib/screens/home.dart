import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ivy/main.dart';
import 'package:ivy/screens/profile.dart';
import 'package:provider/provider.dart';
import 'package:ivy/auth.dart';
import 'post.dart';
import 'package:flutter/services.dart';

// The home page with search
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    firebaseAnalytics.setCurrentScreen(screenName: 'Home Page');
    firebaseAnalytics.logScreenView();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfilePage(),
            ),
          ),
          tooltip: 'Profile',
        ),
        title: const Text('Ivy'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const NewPost())),
      ),
      body: const Search(),
    );
  }
}

// The feed of posts with newest at the top
class Feed extends StatelessWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder(
        // need to handle loading
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return Container();
          }
          return PostList(snapshot);
        },
      ),
    );
  }
}

// The search bar and feed.
// Feed changes to seach when you type a search
class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchBoxController = TextEditingController();
  String dropdownValue = 'Post by Name';

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _searchBoxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchBoxController,
                    autofocus: false,
                    onChanged: (text) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                        labelText: 'Search',
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _searchBoxController.text = '';
                              });
                            },
                            icon: const Icon(Icons.clear))),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                DropdownButton<String>(
                  value: dropdownValue,
                  icon: const Icon(Icons.expand_more),
                  onChanged: (String? newValue) {
                    dropdownValue = newValue!;
                    setState(() {});
                  },
                  // List of all the options available in the drop down menu
                  items: <String>[
                    'Post by Name',
                    'Post by Tag',
                    'Post by Post ID',
                    'User by Name',
                    'User by User ID'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _searchBoxController.text.isEmpty
                  ? const Feed()
                  : Builder(
                      builder: (context) {
                        switch (dropdownValue) {
                          case 'Post by Name':
                            return PostNameList(_searchBoxController.text);

                          case 'Post by Tag':
                            return PostTagList(_searchBoxController.text);
                          case 'Post by Post ID':
                            return PostIDList(_searchBoxController.text);
                          case 'User by Name':
                            return UserNameList(_searchBoxController.text);
                          case 'User by User ID':
                            return UserIDList(_searchBoxController.text);
                          default:
                            return Container();
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Popup to report users
class ReportUserDialog extends StatefulWidget {
  const ReportUserDialog(this.userId, {Key? key}) : super(key: key);
  final String userId;

  @override
  State<ReportUserDialog> createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends State<ReportUserDialog> {
  String dropdownValue = "Spam";
  final TextEditingController _reportUserReasonController =
      TextEditingController();
  late final User currentUser;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    currentUser = context.read<AuthService>().currentUser!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Report User",
          style: TextStyle(fontWeight: FontWeight.bold)),
      scrollable: true,
      content: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text("Select reason for user report:"),
                const SizedBox(
                  height: 8,
                ),
                DropdownButton<String>(
                  itemHeight: 50,
                  isExpanded: true,
                  value: dropdownValue,
                  icon: const Icon(Icons.expand_more),
                  onChanged: (String? newValue) {
                    dropdownValue = newValue!;
                    setState(() {});
                  },
                  // List of all the options available in the drop down menu
                  items: <String>[
                    "Spam",
                    "It appears their account is hacked",
                    "They're pretending to be me or someone else",
                    "Their profile includes abusive or hateful content",
                    "Their messages are abusive or hateful",
                    "They're expressing intention of suicide or self-injury",
                    "They're sharing explicit content",
                    "Other"
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _reportUserReasonController,
                  decoration: const InputDecoration(
                    labelText: "Further detail",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please describe your reason for reporting";
                    }
                    return null;
                  },
                )
              ])),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color.fromARGB(200, 0, 0, 0)),
            )),
        ElevatedButton(
            child: const Text("Submit User Report"),
            onPressed: () {
              // If statement that ensures the user has inputted
              // why they're reporting
              if (_formKey.currentState!.validate()) {
                /*FirebaseFirestore.instance
              .collection("users")
              .doc(widget.userId)
              .collection("reports")
              .add({
                "reason": dropdownValue.toString(),
                "description": _reportUserReasonController.text,
                "timestamp": DateTime.now().millisecondsSinceEpoch,
                "submittedBy": currentUser.uid
              });
              FirebaseFirestore.instance
              .collection("userReports")
              .doc(widget.userId)
              
              .collection("cases")
              .add({
                "reason": dropdownValue.toString(),
                "description": _reportUserReasonController.text,
                "timestamp": DateTime.now().millisecondsSinceEpoch,
                "submittedBy": currentUser.uid
              });*/
                // Thinking of switching it to very wide userReports collection
                // rather than having the cases to group them together
                FirebaseFirestore.instance
                    .collection("userReports")
                    .doc(widget.userId)
                    .set({
                  "reportee": widget.userId,
                  "reason": dropdownValue.toString(),
                  "description": _reportUserReasonController.text,
                  "timestamp": DateTime.now().microsecondsSinceEpoch,
                  "submittedBy": currentUser.uid
                });
                Navigator.pop(context);
              }
            }),
      ],
    );
  }
}

// A scrolling list of posts, newest at the top
class PostList extends StatelessWidget {
  const PostList(this.snapshot, {Key? key}) : super(key: key);
  final AsyncSnapshot<QuerySnapshot> snapshot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.aspectRatio < 1)
          ? MediaQuery.of(context).size.width
          : MediaQuery.of(context).size.height,
      child: ListView(
        children: snapshot.data!.docs.map(
          (e) {
            List<dynamic> tags = e['tags'];
            List<Widget> chips = [];
            for (var tag in tags) {
              chips.add(Padding(
                padding: const EdgeInsets.all(4),
                child: Chip(label: Text(tag)),
              ));
            }

            return InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Post(e.id),
                  ),
                );
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Tooltip(
                        message: e.id,
                        child: Text(
                          'Title: ${e['title']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(e['ownerId'])
                              .get(),
                          builder: (context,
                              AsyncSnapshot<
                                      DocumentSnapshot<Map<String, dynamic>>>
                                  futureSnap) {
                            if (futureSnap.hasError || !futureSnap.hasData) {
                              return Container();
                            }
                            return Tooltip(
                              message: '${e['ownerId']}',
                              child:
                                  Text('By: ${futureSnap.data!.get('name')}'),
                            );
                          }),
                      Text(
                        'Posted: ' +
                            DateTime.fromMillisecondsSinceEpoch(e['timestamp'])
                                .toString()
                                .substring(0, 16),
                      ),
                      if (tags.isNotEmpty && tags.first != '')
                        SizedBox(
                          height: 50,
                          width: 500,
                          child: ListView(
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            children: chips,
                          ),
                        )
                    ],
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

// Scrolling list of posts that have the name(capticalisation agnostic) of the search field
class PostNameList extends StatelessWidget {
  const PostNameList(this.searchText, {Key? key}) : super(key: key);
  final String searchText;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('posts')
          .where('titleSearch', isEqualTo: searchText.toUpperCase())
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return Container();
        }
        return PostList(snapshot);
      },
    );
  }
}

// List of post that have the searched for tag
class PostTagList extends StatelessWidget {
  const PostTagList(this.searchText, {Key? key}) : super(key: key);
  final String searchText;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('posts')
          .where(
            'tags',
            arrayContains: searchText.toUpperCase(),
          )
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return Container();
        }
        return PostList(snapshot);
      },
    );
  }
}

// The post that has the searched postId
class PostIDList extends StatelessWidget {
  const PostIDList(this.searchText, {Key? key}) : super(key: key);
  final String searchText;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          FirebaseFirestore.instance.collection('posts').doc(searchText).get(),
      builder: (context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData || snapshot.hasError || !snapshot.data!.exists) {
          return Container();
        }
        return SizedBox(
          width: (MediaQuery.of(context).size.aspectRatio < 1)
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.height,
          child: ListView(
            children: [
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Post(snapshot.data!.get('id')),
                  ),
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Tooltip(
                          message: snapshot.data!.id,
                          child: Text(
                            'Title: ${snapshot.data!.get('title')}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(snapshot.data!.get('ownerId'))
                                .get(),
                            builder: (context,
                                AsyncSnapshot<
                                        DocumentSnapshot<Map<String, dynamic>>>
                                    futureSnap) {
                              if (futureSnap.hasError || !futureSnap.hasData) {
                                return Container();
                              }
                              return Tooltip(
                                message: '${snapshot.data!.get('ownerId')}',
                                child:
                                    Text('By: ${futureSnap.data!.get('name')}'),
                              );
                            }),
                        Text(
                          'Posted: ' +
                              DateTime.fromMillisecondsSinceEpoch(
                                      snapshot.data!.get('timestamp'))
                                  .toString()
                                  .substring(0, 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// List of users with searched username
class UserNameList extends StatelessWidget {
  const UserNameList(this.searchText, {Key? key}) : super(key: key);
  final String searchText;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: searchText)
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return Container();
        }
        return SizedBox(
          width: (MediaQuery.of(context).size.aspectRatio < 1)
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.height,
          child: ListView(
            children: snapshot.data!.docs.map<Widget>(
              (e) {
                return InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  onTap: () {},
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: LayoutBuilder(
                          builder: (context, BoxConstraints constraints) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            (e['photoURL'] != null)
                                ? Expanded(
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: ClipOval(
                                        child: Image.network(
                                          e['photoURL'],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Icon(
                                        Icons.account_circle,
                                        size: 80,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                  ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              flex: 2,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e['name'],
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(e.id),
                                        IconButton(
                                          onPressed: () {
                                            Clipboard.setData(
                                                    ClipboardData(text: e.id))
                                                .then((_) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          "User ID copied to clipboard")));
                                            });
                                          },
                                          splashRadius:
                                              Material.defaultSplashRadius / 2,
                                          icon: const Icon(
                                            Icons.copy,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            // PLACEHOLDER ICON BUTTON
                            // Depending where we get to with profiles, was thinking
                            // that if you pressed the user card it'll take you to a
                            // dialogue screen but have this iconButton for the time
                            // being as a placeholder, the widget dialogue can be
                            // copied over for any profile screen
                            IconButton(
                              tooltip: "Report user for improper behaviour",
                              splashRadius: Material.defaultSplashRadius / 2,
                              icon: const Icon(
                                Icons.report,
                                color: Color.fromARGB(150, 255, 0, 0),
                                size: 18,
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ReportUserDialog(e.id);
                                    });
                              },
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}

// User with searched userId
class UserIDList extends StatelessWidget {
  const UserIDList(this.searchText, {Key? key}) : super(key: key);
  final String searchText;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          FirebaseFirestore.instance.collection('users').doc(searchText).get(),
      builder: (context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData || snapshot.hasError || !snapshot.data!.exists) {
          return Container();
        }
        return SizedBox(
          width: (MediaQuery.of(context).size.aspectRatio < 1)
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.height,
          child: ListView(
            children: [
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                onTap: () {},
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        (snapshot.data!.get('photoURL') != null)
                            ? Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipOval(
                                    child: Image.network(
                                      snapshot.data!.get('photoURL'),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              )
                            : Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Icon(
                                    Icons.account_circle,
                                    size: 80,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                ),
                              ),
                        const SizedBox(
                          width: 8,
                        ),

                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data!.get('name'),
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(snapshot.data!.id),
                                    IconButton(
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                                text: snapshot.data!.id))
                                            .then(
                                          (_) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "User ID copied to clipboard")));
                                          },
                                        );
                                      },
                                      splashRadius:
                                          Material.defaultSplashRadius / 2,
                                      icon: const Icon(
                                        Icons.copy,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        // PLACEHOLDER ICON BUTTON
                        // Depending where we get to with profiles, was thinking
                        // that if you pressed the user card it'll take you to a
                        // dialogue screen but have this iconButton for the time
                        // being as a placeholder, the widget dialogue can be
                        // copied over for any profile screen
                        IconButton(
                          tooltip: "Report user for improper behaviour",
                          splashRadius: Material.defaultSplashRadius / 2,
                          icon: const Icon(
                            Icons.report,
                            color: Color.fromARGB(150, 255, 0, 0),
                            size: 18,
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ReportUserDialog(snapshot.data!.id);
                                });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
