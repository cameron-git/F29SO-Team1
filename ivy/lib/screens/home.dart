import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ivy'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              label: 'Home',
              icon: IconButton(
                icon: Icon(Icons.home),
                onPressed: () => Navigator.pushNamed(context, '/'),
              )),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ),
        ],
      ),
    );
  }
}
