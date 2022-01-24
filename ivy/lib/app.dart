import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'screens/home.dart';

class IvyApp extends StatelessWidget {
  const IvyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ivy',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      routes: <String, WidgetBuilder>{
        '/': (context) => MainPage(),
        '/profile': (context) => ProfileScreen(
              providerConfigs: [
                EmailProviderConfiguration(),
              ],
              actions: [
                SignedOutAction(
                  (context) {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ],
            ),
      },
    );
  }
}
