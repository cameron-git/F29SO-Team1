import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ivy/screens/message.dart';
import 'package:ivy/screens/search.dart';

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
          onPressed: () => Navigator.pushNamed(context, '/profile'),
          tooltip: 'Profile',
        ),
        title: const Text('Ivy'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: (index) {
          setState(() {
            pageIndex = index;
          });
          pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 150),
            curve: Curves.ease,
          );
        },
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(
              Icons.home,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Search',
            icon: Icon(
              Icons.search,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Message',
            icon: Icon(
              Icons.message_outlined,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/newpost'),
        backgroundColor: Colors.lightGreen,
        foregroundColor: Colors.white,
      ),
      body: PageView(
        onPageChanged: (index) => setState(() {
          pageIndex = index;
        }),
        controller: pageController,
        children: const [
          Feed(),
          Search(),
          MessagePage(),
        ],
      ),
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
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, '/post', arguments: e.id),
                    child: Card(
                      child: Column(
                        children: [
                          Text(e['name'].toString()),
                          Text(e['title']),
                          Text(
                            DateTime.fromMillisecondsSinceEpoch(e['timestamp'])
                                .toString()
                                .substring(0, 16),
                          ),
                        ],
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
