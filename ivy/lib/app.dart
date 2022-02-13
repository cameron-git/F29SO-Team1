import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ivy/auth.dart';
import 'package:ivy/screens/login.dart';

import 'package:ivy/screens/profile.dart';
import 'package:ivy/screens/home.dart';
import 'package:ivy/screens/post.dart';
import 'package:provider/provider.dart';

// The main app class
class IvyApp extends StatelessWidget {
  const IvyApp({Key? key}) : super(key: key);

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
        debugShowCheckedModeBanner: false, // Remove later
        title: 'Ivy',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF73C597),
            foregroundColor: Colors.white,
          ),
          primarySwatch: const MaterialColor(
            0xFF73C597,
            <int, Color>{
              50: Color(0xFF73C597),
              100: Color(0xFF73C597),
              200: Color(0xFF73C597),
              300: Color(0xFF73C597),
              400: Color(0xFF73C597),
              500: Color(0xFF73C597),
              600: Color(0xFF73C597),
              700: Color(0xFF73C597),
              800: Color(0xFF73C597),
              900: Color(0xFF73C597),
            },
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
