import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ivy/auth.dart';
import 'package:ivy/screens/admin.dart';
import 'package:ivy/screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';
import 'post.dart';



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final pageController = PageController();
  int pageIndex = 0;
  bool adminBool = true;
  String check = " NOPE";
  String thisUser = FirebaseAuth.instance.currentUser!.uid.toString();
  late final User currentUser;
  var thisThing = null;
  
  
  void initState() {
    currentUser = context.read<AuthService>().currentUser!;
    thisThing = FirebaseFirestore.instance
        .collection("posts")
        .doc("2FfE7iypRHL3DtsYhvlS")
        .get();
      //.then((value) {
     // adminBool = true;
    

    //thisThing = FirebaseFirestore.instance
    ///  .collection("users")
   //   .doc(currentUser.uid)
   //   .get();
      /*.then((value){
        check = "not this";
      });*/

    //final Stream<DocumentSnapshot> _checkStream=
      /*FirebaseFirestore.instance
      .collection("users")
      .doc(currentUser.uid)
      .get()
      .then((value){
        check = "not this";
      });*/


      /*check = "this";
      //FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get()
        .then((value){
          check = "not this";
        });

*/

    super.initState();

  }



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
        // Displays button to admin page at top right along the app bar

        actions: [
          Text(thisThing.toString()),
          //Text("       "+currentUser.uid),
          Text(check.toString()),
          Container(
            // If adminBool is true, creates icon button
            child: adminBool?
              IconButton(
                // Change this to whatever you want
                icon: Image.asset("assets/admin.png"),
                iconSize: 50,
                color: Colors.black,
                onPressed:(){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminUI()),
                    );
                },
              )
              : // Ternary operator, if user isn't admin, showes second option (nothing)
              Text("")
          )
        ]
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
                          FirebaseFirestore.instance
                              .collection('users')
                              .where('name',
                                  isEqualTo: _searchBoxController.text)
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
                        List<QueryDocumentSnapshot<Object?>> users =
                            snapshot.data!.elementAt(2).docs;
                        List<Widget> listItems = users.map(
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
                                onTap: () {},
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        (e['photoURL'] != null)
                                            ? ClipOval(
                                                child: Image.network(
                                                  e['photoURL'],
                                                  width: 64,
                                                  height: 64,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Icon(
                                                Icons.account_circle,
                                                size: 64,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                              ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(e['name']),
                                            Text(e['email']),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList();
                        listItems.addAll(
                          posts.map(
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
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Post(e.id))),
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
                        return ListView(
                          children: listItems,
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
