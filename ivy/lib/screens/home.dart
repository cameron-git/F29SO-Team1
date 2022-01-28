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
        ),
        title: const Text('Ivy'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(
              Icons.home,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Messaging',
            icon: Icon(
              Icons.message,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: GridView.count(
        crossAxisCount: 3,
        children: [
          Card(
            child: Text('Post 1'),
            elevation: 10,
          ),
          Card(
            child: Text('Post 1'),
            elevation: 10,
          ),
          Card(
            child: Text('Post 1'),
            elevation: 10,
          ),
          Card(
            child: Text('Post 1'),
            elevation: 10,
          ),
          Card(
            child: Text('Post 1'),
            elevation: 10,
          ),
          Card(
            child: Text('Post 1'),
            elevation: 10,
          ),
          Card(
            child: Text('Post 1'),
            elevation: 10,
          ),
          Card(
            child: Text('Post 1'),
            elevation: 10,
          ),
          Card(
            child: Text('Post 1'),
            elevation: 10,
          ),
          Card(
            child: Text('Post 1'),
            elevation: 10,
          ),
          Card(
            child: Text('Post 1'),
            elevation: 10,
          ),
        ],
      ),
    );
  }
}
