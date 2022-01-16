import 'package:flutter/material.dart';
import 'package:ivy/constants.dart';

circularProgress() {
  return Container(
    // centers both horizontally and vertically
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(secondaryColour),
    ),
  );
}

linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(secondaryColour),
    ),
  );
}
