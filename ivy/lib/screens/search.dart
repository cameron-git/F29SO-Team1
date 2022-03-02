import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

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
              autofocus: true,
              onChanged: (text) {
                setState(() {});
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder(
                // need to handle loading
                future: Future.wait(
                  [
                    FirebaseFirestore.instance
                        .collection('posts')
                        .where('title', isEqualTo: _searchBoxController.text)
                        .get(),
                    FirebaseFirestore.instance
                        .collection('posts')
                        .where(
                          'tags',
                          arrayContains: _searchBoxController.text,
                        )
                        .get(),
                  ],
                ),
                builder:
                    (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            onTap: () => Navigator.pushNamed(context, '/post',
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
