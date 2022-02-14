import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignInScreen(
        actions: [
          AuthStateChangeAction<SignedIn>((context, _) {}),
        ],
        providerConfigs: const [
          EmailProviderConfiguration(),
        ],
        headerMaxExtent: 300,
        headerBuilder: (context, constraints, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset('assets/ivy-logo-3.png'),
            ),
          ),
        ),
        sideBuilder: (context, constraints) => Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: constraints.constrainWidth(540),
            height: constraints.constrainHeight(540),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset('assets/ivy-logo-3.png'),
            ),
          ),
        ),
        footerBuilder: (context, action) => const Padding(
          padding: EdgeInsets.all(12),
          child: Text('ToS applies!!!'),
        ),
      ),
    );
  }
}
