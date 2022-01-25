import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
