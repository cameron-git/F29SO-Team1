/*
Ivy Collaberative Social Media App

App structure:
  /screens: Widgets for each screen is stored here

    home: Home page, includes search and feed
    post: The post page, also includes the widget for creating a new post and a function for deleting posts
    profile: The profile page, allows changing user info, settings and signing out
    login: The sign in page
  /theme:
    theme_service.dart: Handles saving users theme choices to device storage and provides functions for changing theme.
  /widgets:
    video_player: A wrapper stateful widget to manage the state of the VideoPlayer widget
    voice_call: Contains a widget for a voice call button. Also contains the state relating to joining and leaving the voice call. Requries the signalling server url to be set. Only works up to 2 peers
  auth: Contains a class that is provided to the rest of the app that manages user authentication state and provides functions to interface with the firebase authentication service.
  constants: Some constants used in the app
  firebase_options: firebase generated configs
  generated_plugin_registrant: generated file, do not edit
  main: main function and main "Ivy" widget that is first opened. The Ivy widget acts as a wrapper and with the help of other wrappers decides the users credentials and what page they should be sent to

*/

// imports core flutter libraries

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// importing firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:ivy/firebase_options.dart';

import 'package:ivy/auth.dart';
import 'package:ivy/screens/admin.dart';
import 'package:ivy/screens/login.dart';
import 'package:ivy/screens/home.dart';
import 'package:ivy/theme/theme_service.dart';
import 'package:provider/provider.dart';

var auth = FirebaseAuth.instance;
var firebaseAnalytics = FirebaseAnalytics.instance;

// Starting the app and firebase config
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialising FlutterFire
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  firebaseAnalytics.logAppOpen();
  runApp(const IvyApp());
}

ThemeService themeService = ThemeService();

// The main app class
class IvyApp extends StatefulWidget {
  const IvyApp({Key? key}) : super(key: key);

  @override
  State<IvyApp> createState() => _IvyAppState();
}

class _IvyAppState extends State<IvyApp> {
  @override
  void dispose() {
    themeService.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    themeService.initialize();
    themeService.addListener(themeListener);
    super.initState();
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: null,
        )
      ],
      child: MaterialApp(
        // Sets theme
        themeMode: themeService.themeMode,
        debugShowCheckedModeBanner: false, // Remove later
        title: 'Ivy',
        // The light theme
        theme: ThemeData(
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              foregroundColor: Colors.white),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 2,
              ),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF73C597),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black54,
            showSelectedLabels: false,
            showUnselectedLabels: false,
          ),
          colorScheme: const ColorScheme.light().copyWith(
            primary: const Color(0xFF73C597),
            secondary: const Color(0xFF73C597),
            onBackground: Colors.black54,
          ),
        ),
        // The dark theme
        darkTheme: ThemeData(
          snackBarTheme: const SnackBarThemeData(
              contentTextStyle: TextStyle(color: Colors.white)),
          textTheme: const TextTheme(
            bodyText1: TextStyle(),
            bodyText2: TextStyle(),
            headline6: TextStyle(),
          ).apply(
            bodyColor: Colors.grey.shade300,
            displayColor: const Color(0xFF73C597),
          ),
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 2,
              ),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF73C597),
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black54,
            showSelectedLabels: false,
            showUnselectedLabels: false,
          ),
          colorScheme: const ColorScheme.dark().copyWith(
            primary: const Color(0xFF73C597),
            secondary: const Color(0xFF73C597),
            surface: const Color(0xFF73C597),
            onSurface: Colors.black,
            background: const Color(0xFF303030),
            onBackground: Colors.white54,
          ),
        ),
        // The wrapper that first gets shown when opening the app
        home: const AuthWrapper(),
      ),
    );
  }
}

// Checks if the user is signed in and sends them to login page if not
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    if (firebaseUser == null) {
      return const LoginPage();
    } else {
      firebaseAnalytics.setUserId(id: firebaseUser.uid);
      return const HopePageWrapper();
    }
  }
}

// Checks if the user is an admin and sends them to the correct UI
class HopePageWrapper extends StatelessWidget {
  const HopePageWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('admins')
          .doc(context.read<AuthService>().currentUser!.uid)
          .snapshots(),
      builder: (context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          debugPrint('hey');
          return Container();
        }
        if (!snapshot.data!.exists) {
          return const HomePage();
        } else {
          return const AdminUI();
        }
      },
    );
  }
}
