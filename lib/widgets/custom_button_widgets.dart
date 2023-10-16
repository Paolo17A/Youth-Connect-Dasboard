import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget editEntryButton(BuildContext context, {required Function onPress}) {
  return ElevatedButton(
      onPressed: () {
        onPress();
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
      child: const Icon(Icons.edit, color: Colors.white));
}

Widget deleteEntryButton(BuildContext context, {required Function onPress}) {
  return ElevatedButton(
      onPressed: () {
        onPress();
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Icon(Icons.delete, color: Colors.white));
}

Widget restoreEntryButton(BuildContext context, {required Function onPress}) {
  return ElevatedButton(
      onPressed: () {
        onPress();
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      child: const Icon(Icons.restart_alt, color: Colors.white));
}

Widget downloadFileButton(BuildContext context, {required Function onPress}) {
  return ElevatedButton(
      onPressed: () {
        onPress();
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      child: const Icon(Icons.download, color: Colors.white));
}

Widget viewEntryButton(Function onPress) {
  return ElevatedButton(
    onPressed: () {
      onPress();
    },
    child: AutoSizeText('VIEW ENTRY',
        style: GoogleFonts.inter(
            textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold))),
  );
}
