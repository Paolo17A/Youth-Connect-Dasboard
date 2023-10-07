import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget submitButton(
    {required BuildContext context,
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
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      onPressed: () {
        submitFunction();
      },
      child: Text('SUBMIT',
          style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 14))),
    ),
  );
}
