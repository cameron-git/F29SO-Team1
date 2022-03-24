import 'package:flutter/material.dart ';
import 'package:ivy/auth.dart';
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
            TextButton(
              child: Container(
                color: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    viewPosts
                        ? 'Click to view Reported Users'
                        : 'Click to view Reported Posts',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              onPressed: () {
                setState(() {
                  viewPosts = !viewPosts;
                });
              },
            ),
            TextButton(
              child: Container(
                color: Colors.black12,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'View Ivy Statistics',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              onPressed: () {
/* 
Use an alertDialog like used in Post() to show a popup with the data from the Requirements
 */
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthService>().signOut();
              },
            ),
            /*IconButton(
            icon: Image.asset("assets/admin.png"),
            iconSize: 50,
            onPressed: (){},
            */
          ]),
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
*/
class ReportedPostList extends StatefulWidget {
  const ReportedPostList({Key? key}) : super(key: key);

  @override
  State<ReportedPostList> createState() => _ReportedPostListState();
}

class _ReportedPostListState extends State<ReportedPostList> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

/* 
Same as above but for Users
 */
class ReportedUserList extends StatefulWidget {
  const ReportedUserList({Key? key}) : super(key: key);

  @override
  State<ReportedUserList> createState() => _ReportedUserListState();
}

class _ReportedUserListState extends State<ReportedUserList> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
