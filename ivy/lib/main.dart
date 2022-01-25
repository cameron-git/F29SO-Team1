/*
Ivy Collaberative Social Media App

App structure:
  /screens: Widgets for each screen is stored here
    feed: The feed page
    home: Home page
    new_post:
    profile:
    search:
  /widgets:
  app: The app main file
  firebase_options: firebase generated configs
  generated_plugin_registrant: generated file, do not edit
  main: main function

*/

// imports core flutter libraries
import 'package:flutter/material.dart';

// importing firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:ivy/firebase_options.dart';

// imports the app
import 'package:ivy/app.dart';

// Starting the app and firebase config
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const IvyApp());
}
