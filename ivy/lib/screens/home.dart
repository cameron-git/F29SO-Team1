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
      body: GridView.count(
        crossAxisCount: 3,
        children: [],
      ),
    );
  }
}
