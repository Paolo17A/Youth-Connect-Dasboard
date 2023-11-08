import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/color_util.dart';
import 'custom_text_widgets.dart';

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

Widget submitButton(BuildContext context,
    {required String text,
    required Function() submitFunction,
    required width,
    required height}) {
  return SizedBox(
    width: width,
    height: height,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 34, 52, 189),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      onPressed: () {
        submitFunction();
      },
      child: Text(text,
          style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 14))),
    ),
  );
}

Widget registerActionButton(String text, Function onPress) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
            onPressed: () => onPress(),
            style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.darkBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            child: Text(
              text,
              style: whiteBoldStyle(size: 15),
            ))
      ],
    ),
  );
}
