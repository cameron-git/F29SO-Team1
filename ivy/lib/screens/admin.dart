import 'dart:html';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
                    Use an alertDialog like used in Post() 
                    to show a popup with the data from the Requirements
                  */
                  showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return StatDialog();
                    },
                  );
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
              ];
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthService>().signOut();
            },
          ),
        ],
      ),
      body: viewPosts ? const ReportedPostList() : const ReportedUserList(),
    );
  }
}

class StatDialog extends StatefulWidget{
  const StatDialog({Key? key}) :super(key:key);
  //final String postId;

  @override
  State<StatDialog> createState() => _StatDialogState();
}

class _StatDialogState extends State<StatDialog>{
  FirebaseFirestore db1 = FirebaseFirestore.instance;
  int size = 0;

  
  @override
  void initState(){
    size = 2; // Just to see that it was possible to change the value from initState()
    //
    // The troublemaker ⏬
    //
    db1.collection("posts").get().then((querySnapshot){
      size = querySnapshot.size;
    });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context){
    return AlertDialog(
      title: 
        const Text("Ivy Platform Statistics ",
        //style: TextStyle(decoration:TextDecoration.underline),
        ),
      scrollable: true,
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          child: Column(children: <Widget>[
            const Padding(
              padding: EdgeInsets.zero,
              child: Text("Total number of posts:"),
            ),
            // 
            // THEN THIS BIT
            //
            Padding(
              padding: EdgeInsets.zero,
              child: Text(
                size.toString()
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: const [
                  Text("test"), Text("    this"),
                ],
              )
            )
          ]
          )
        )
        
      ),
      actions: [
        TextButton(
          child: const Text("hello"),
          onPressed:(){
            FirebaseFirestore.instance
            .collection("thisWorks")
            .add(
              {
                "tada": "this",
              }
            );
            
          }
        )
      ],

      

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


