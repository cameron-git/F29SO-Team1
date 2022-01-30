import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ivy/screens/login.dart';
import 'package:ivy/screens/message.dart';
import 'package:ivy/screens/profile.dart';
import 'package:ivy/screens/home.dart';
import 'package:ivy/screens/post.dart';

// The main app class
class IvyApp extends StatelessWidget {
  const IvyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove later
      title: 'Ivy',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // Creates NamesRoutes for the pages of the app
      // Makes switching pages easier
      initialRoute: '/login',
      routes: <String, WidgetBuilder>{
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/profile': (context) => ProfilePage(),
        '/post': (context) => Post(),
        '/newpost': (context) => NewPost(),
      },
    );
  }
}
