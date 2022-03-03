/*
Ivy Collaberative Social Media App

App structure:
  /screens: Widgets for each screen is stored here
    feed: The feed page
    home: Home page
    new_post:
    profile:
    search:
  /widgets:
  firebase_options: firebase generated configs
  generated_plugin_registrant: generated file, do not edit
  main: main and app

*/

// imports core flutter libraries
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// importing firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:ivy/firebase_options.dart';

import 'package:ivy/auth.dart';
import 'package:ivy/screens/login.dart';
import 'package:ivy/screens/home.dart';
import 'package:provider/provider.dart';

var auth = FirebaseAuth.instance;

// Starting the app and firebase config
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialising FlutterFire
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const IvyApp());
}

// The main app class
class IvyApp extends StatefulWidget {
  const IvyApp({Key? key}) : super(key: key);

  @override
  State<IvyApp> createState() => _IvyAppState();
}

class _IvyAppState extends State<IvyApp> {
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
        // themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false, // Remove later
        title: 'Ivy',
        theme: ThemeData(
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              foregroundColor: Colors.white),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
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
        darkTheme: ThemeData(
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
            onBackground: Colors.white54,
          ),
        ),
        // Creates NamesRoutes for the pages of the app
        // Makes switching pages easier
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    if (firebaseUser == null) {
      return const LoginPage();
    } else {
      return const HomePage();
    }
  }
}
