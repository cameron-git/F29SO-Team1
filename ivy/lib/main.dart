import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterfire_ui/auth.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ivy',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LogInPage(),
    );
  }
}

class LogInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providerConfigs: [
        GoogleProviderConfiguration(clientId: ''),
        EmailProviderConfiguration(),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ivy'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[const Text('Welcome to Iiiiivvvvyyyyy')],
        )));
  }
}
