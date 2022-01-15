import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ivy'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset('assets/ivy-logo.png'),
    );
  }
}
