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
