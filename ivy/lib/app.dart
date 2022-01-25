import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ivy/screens/login.dart';
import 'package:ivy/screens/profile.dart';
import 'package:ivy/screens/home.dart';

// The main app class
class IvyApp extends StatelessWidget {
  const IvyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ivy',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // Creates NamesRoutes for the pages of the app
      // Makes switching pages easier
      routes: <String, WidgetBuilder>{
        '/': (context) =>
            AuthWrapper(), // By default this Map pair is the home widget
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}

// Shows users who are not signed in the sign in screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoginPage();
          } else {
            return HomePage();
          }
        });
  }
}
