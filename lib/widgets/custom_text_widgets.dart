import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle interSize19() {
  return GoogleFonts.inter(textStyle: const TextStyle(fontSize: 19));
}

TextStyle viewEntryStyle(Color thisColor) {
  return GoogleFonts.inter(
      textStyle: TextStyle(
          color: thisColor, fontSize: 23, fontWeight: FontWeight.bold));
}

TextStyle blackBoldStyle({double? size = 20}) {
  return TextStyle(
      color: Colors.black, fontWeight: FontWeight.bold, fontSize: size);
}

TextStyle blackThinStyle({double? size = 20}) {
  return TextStyle(
      color: Colors.black, fontWeight: FontWeight.w500, fontSize: size);
}

TextStyle whiteBoldStyle({double? size = 20}) {
  return TextStyle(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: size);
}

TextStyle whiteThinStyle({double? size = 20}) {
  return TextStyle(
      color: Colors.white, fontWeight: FontWeight.w200, fontSize: size);
}

TextStyle yellowBoldStyle({double? size = 20}) {
  return TextStyle(
      color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: size);
}

TextStyle greyThinStyle({double? size = 20}) {
  return TextStyle(
      color: Colors.grey, fontWeight: FontWeight.w200, fontSize: size);
}

TextStyle titleTextStyle() {
  return TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
}

TextStyle contentTextStyle() {
  return TextStyle(overflow: TextOverflow.ellipsis, fontSize: 15);
}
