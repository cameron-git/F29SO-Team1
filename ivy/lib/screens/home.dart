import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ivy/screens/message.dart';
import 'package:ivy/screens/profile.dart';
import 'package:ivy/screens/search.dart';

import 'post.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final pageController = PageController();
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
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
      body: Search(),
    );
  }
}

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
          if (!snapshot.hasData) {
            return Container();
          }
          return ListView(
            children: snapshot.data!.docs.map(
              (e) {
                return Padding(
                  padding: (MediaQuery.of(context).size.width /
                              MediaQuery.of(context).size.height <
                          15 / 9)
                      ? const EdgeInsets.all(8)
                      : EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width / 3,
                          8,
                          MediaQuery.of(context).size.width / 3,
                          8),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Post(e.id),
                      ),
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Text(e['title']),
                            Text(
                              DateTime.fromMillisecondsSinceEpoch(
                                      e['timestamp'])
                                  .toString()
                                  .substring(0, 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          );
        },
      ),
    );
  }
}

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchBoxController = TextEditingController();

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
            TextField(
              controller: _searchBoxController,
              autofocus: false,
              onChanged: (text) {
                setState(() {});
              },
              decoration: const InputDecoration(
                labelText: 'Search',
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _searchBoxController.text.isEmpty
                  ? const Feed()
                  : FutureBuilder(
                      // need to handle loading
                      future: Future.wait(
                        [
                          FirebaseFirestore.instance
                              .collection('posts')
                              .where('title',
                                  isGreaterThanOrEqualTo:
                                      _searchBoxController.text)
                              .get(),
                          FirebaseFirestore.instance
                              .collection('posts')
                              .where(
                                'tags',
                                arrayContains:
                                    _searchBoxController.text.toUpperCase(),
                              )
                              .get(),
                        ],
                      ),
                      builder: (context,
                          AsyncSnapshot<List<QuerySnapshot>> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        List<QueryDocumentSnapshot<Object?>> posts =
                            snapshot.data!.elementAt(0).docs;
                        posts.addAll(snapshot.data!.elementAt(1).docs);

                        return ListView(
                          children: posts.map(
                            (e) {
                              return Padding(
                                padding: (MediaQuery.of(context).size.width /
                                            MediaQuery.of(context).size.height <
                                        15 / 9)
                                    ? const EdgeInsets.fromLTRB(0, 8, 0, 8)
                                    : EdgeInsets.fromLTRB(
                                        MediaQuery.of(context).size.width / 3,
                                        8,
                                        MediaQuery.of(context).size.width / 3,
                                        8),
                                child: InkWell(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  onTap: () => Navigator.pushNamed(
                                      context, '/post',
                                      arguments: e.id),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(30),
                                      child: Column(
                                        children: [
                                          // Text(e['name'].toString()),
                                          Text(e['title']),
                                          Text(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                    e['timestamp'])
                                                .toString()
                                                .substring(0, 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
