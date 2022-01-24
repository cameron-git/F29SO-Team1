import 'package:flutter/material.dart';

// colours for our app
Color primaryColour = HexColor("73C597");
Color secondaryColour = HexColor("149994");
Color textColour = HexColor("010706");
Color backgroundColor = HexColor("D2D3BD");

// converting from hex to argb
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
