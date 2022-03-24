import 'package:flutter/material.dart ';
import 'package:ivy/auth.dart';
import 'package:provider/provider.dart';

class AdminUI extends StatefulWidget {
  const AdminUI({Key? key}) : super(key: key);

  @override
  State<AdminUI> createState() => _AdminUIState();
}

class _AdminUIState extends State<AdminUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthService>().signOut();
            },
          ),
          title: const Text('Admin Panel'),
          backgroundColor: Colors.deepOrange),
      body: Container(),
    );
  }
}
