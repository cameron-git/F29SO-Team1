import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ivy/auth.dart';
import 'package:provider/provider.dart';

// This Widget is adapted from the ProfileScreen Widget from the FlutterFire_UI package which is under the BSD-3-Clause license
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String dropdownValue = 'System';

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<AuthService>().currentUser;
    late final usernameContoller =
        TextEditingController(text: user?.displayName ?? '');

    Widget editPhoto() {
      if (user?.photoURL != null) {
        return ClipOval(
          child: Image.network(
            user!.photoURL!,
            width: 128,
            height: 128,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Icon(
          Icons.account_circle,
          size: 128,
          color: Theme.of(context).colorScheme.onBackground,
        );
      }
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Edit Profile Picture",
          style: TextStyle(fontSize: 10),
        ),
        InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(72)),
            onTap: () async {
              final results = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                type: FileType.custom,
                allowedExtensions: ['png', 'jpg'],
              );
              // if no file was chosen, tell the user
              if (results == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No file selected.'),
                  ),
                );
                return;
              }
              // if the app is running on the web
              if (kIsWeb) {
                final bytes =
                    results.files.single.bytes!; // get the selected file

                // upload the image to firebase storage
                await FirebaseStorage.instance
                    .ref('ProfilePics/${user?.uid}')
                    .putData(bytes);

                // if the app is hosted on a mobile device
              } else {
                final path = results.files.single.path!;

                // upload the image to firebase storage
                await FirebaseStorage.instance
                    .ref('ProfilePics/${user?.uid}')
                    .putFile(File(path));
              }

              final url = await FirebaseStorage.instance
                  .ref('ProfilePics/${user?.uid}')
                  .getDownloadURL();
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .update(
                {
                  'photoURL': url,
                },
              );
              user?.updatePhotoURL(url);
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: editPhoto(),
            )),
        const SizedBox(height: 16),
        TextField(
          autofocus: false,
          controller: usernameContoller,
          decoration: const InputDecoration(
              hintText: 'Username', labelText: 'Edit Username'),
          onSubmitted: (_) async {
            if (user?.displayName == usernameContoller.text) return;
            await user?.updateDisplayName(usernameContoller.text);
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .update(
              {'name': usernameContoller.text},
            );
            await user?.reload();
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Theme:'),
            DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.expand_more),
              onChanged: (String? newValue) {
                dropdownValue = newValue!;
                setState(() {});
              },
              // List of all the options available in the drop down menu
              items: <String>[
                'System',
                'Light',
                'Dark',
              ].map<DropdownMenuItem<String>>(
                (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(value),
                    ),
                  );
                },
              ).toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 200,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey, width: 2),
            ),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .delete();

              user?.delete();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Delete Account',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(context.watch<AuthService>().currentUser?.displayName ??
              'User is null'),
          actions: [
            IconButton(
              onPressed: () {
                context.read<AuthService>().signOut();
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.logout_outlined,
              ),
            )
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 500) {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: content,
                      );
                    } else {
                      return content;
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
