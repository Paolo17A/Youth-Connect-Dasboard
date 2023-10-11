import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar appBarWidget(BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        Image.asset('assets/images/ywda_logo.png', scale: 3.25),
        Text('YOUTH DEVELOPMENT AFFAIRS',
            style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 25))),
      ],
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
            onPressed: () {
              GoRouter.of(context).go('/adminSettings');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 88, 147, 201),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: Text('Admin',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w800))),
      )
    ],
  );
}
