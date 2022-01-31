import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      actions: [
        AuthStateChangeAction<SignedIn>((context, _) {
          Navigator.pushReplacementNamed(context, '/home');
        }),
      ],
      providerConfigs: const [
        EmailProviderConfiguration(),
      ],
      headerMaxExtent: 300,
      headerBuilder: (context, constraints, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          color: const Color(0xFF73C597),
          child: Row(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/ivy-logo-cut.png'),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'IVY',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFF7F4E6),
                    ),
                  ),
                  Text(
                    'Learn Together, Whenever',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF7F4E6),
                    ),
                  ),
                ],
              ),
            ],
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
            child: Image.asset('assets/ivy-logo.png'),
          ),
        ),
      ),
      footerBuilder: (context, action) => const Padding(
        padding: EdgeInsets.all(12),
        child: Text('ToS applies!!!'),
      ),
    );
  }
}
