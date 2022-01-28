import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Profile',
          ),
          title: const Text('Ivy'),
        ),
        bottomNavigationBar: BottomAppBar(
          notchMargin: 5,
          shape: CircularNotchedRectangle(),
          color: Colors.green,
          child: BottomNavigationBar(
            currentIndex: 0,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.white,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                label: 'Home',
                icon: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.home,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: 'Search',
                icon: IconButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/search'),
                  icon: const Icon(
                    Icons.search,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: 'Message',
                icon: IconButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/message'),
                  icon: const Icon(
                    Icons.message,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 0,
          child: const Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/newpost'),
          backgroundColor: Colors.lightGreen,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: Center(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return ListView(
                children: snapshot.data!.docs.map(
                  (e) {
                    return ListTile(
                      title: Text(e['name'].toString() + ' ' + e['userId']),
                      subtitle: Text(
                        DateTime.fromMillisecondsSinceEpoch(
                          e['timestamp'],
                        ).toString().substring(0, 16),
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ),
        ));
  }
}
