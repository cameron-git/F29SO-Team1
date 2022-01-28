import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      providerConfigs: [
        EmailProviderConfiguration(),
      ],
      actions: [
        SignedOutAction(
          (context) {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }
}
