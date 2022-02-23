import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  // method to upload images to the firebase storage
  Future<void> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);

    try {
      await storage.ref('images/$fileName').putFile(file);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  // method to download images from the firebase storage
  Future<String> downloadURL(String fileName) async {
    String downloadURL = await storage.ref('images/$fileName').getDownloadURL();

    return downloadURL;
  }
}
