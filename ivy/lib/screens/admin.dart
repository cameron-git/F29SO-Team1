import 'package:flutter/material.dart ';
import 'package:ivy/auth.dart';
import 'package:ivy/screens/post.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminUI extends StatefulWidget {
  const AdminUI({Key? key}) : super(key: key);

  @override
  State<AdminUI> createState() => _AdminUIState();
}

class _AdminUIState extends State<AdminUI> {
  bool viewPosts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('Ivy - Admin Panel'),
        // Displays button to admin page at top right along the app bar
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 1:
                  setState(() {
                    viewPosts = !viewPosts;
                  });
                  break;
                case 2:
                  /* 
Use an alertDialog like used in Post() to show a popup with the data from the Requirements
 */
                  break;
                case 3:
                  context.read<AuthService>().signOut();
                  break;
                default:
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text(
                    viewPosts
                        ? 'Click to view Reported Users'
                        : 'Click to view Reported Posts',
                  ),
                  value: 1,
                ),
                const PopupMenuItem(
                  child: Text(
                    'Click to view Ivy Statistics',
                  ),
                  value: 2,
                ),
                const PopupMenuItem(
                  child: Text(
                    'Sign out',
                  ),
                  value: 3,
                ),
              ];
            },
          ),
        ],
      ),
      body: viewPosts ? const ReportedPostList() : const ReportedUserList(),
    );
  }
}

/* This Widget should create a streambuilder list of posts like how Feed does
however should use a seperate collection to store which postId are reported and
why and by who. For the 'reportedPosts' collection you can use the same uid as
the orginal post when making the documents.

Dont bother changing Post.dart functionality. Just add admin functionality to
the buttons. One of the buttons should tell the admin howmany times/why the post
was reported

Try if possible to keep all code related to this admin page within this file.
I have created a Streambuilder in main.dart so that the adminUI widget is shown
if the user is an admin
*/
class ReportedPostList extends StatelessWidget {
  const ReportedPostList({Key? key}) : super(key: key);

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

/* 
Same as above but for Users
 */
class ReportedUserList extends StatelessWidget {
  const ReportedUserList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
