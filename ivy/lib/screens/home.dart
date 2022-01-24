import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ivy/screens/feed.dart';
import 'package:ivy/screens/new_post.dart';
import 'package:ivy/screens/profile.dart';
import 'package:ivy/screens/search.dart';
import 'package:ivy/app.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ivy'),
      ),
      body: HomeScreen(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomePage();
        } else {
          return SignInScreen(
            providerConfigs: [
              EmailProviderConfiguration(),
            ],
            headerBuilder: (context, constraints, _) => Padding(
              padding: EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset('assets/ivy-logo.png'),
              ),
            ),
            sideBuilder: (context, constraints) => Padding(
              padding: EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset('assets/ivy-logo.png'),
              ),
            ),
            footerBuilder: (context, action) => Padding(
              padding: EdgeInsets.all(12),
              child: Text('ToS applies!!!'),
            ),
          );
        }
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            label: 'Profile2',
            icon: Icon(Icons.account_circle),
          ),
          BottomNavigationBarItem(
            label: 'Profile1',
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
