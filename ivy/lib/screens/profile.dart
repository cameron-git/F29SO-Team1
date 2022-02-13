import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:ivy/auth.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      providerConfigs: const [
        EmailProviderConfiguration(),
      ],
      actions: [
        SignedOutAction(
          (context) {
            context.read<AuthService>().signOut();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
