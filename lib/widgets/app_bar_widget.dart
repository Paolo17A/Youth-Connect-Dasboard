import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/widgets/custom_text_widgets.dart';

AppBar appBarWidget(BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        Image.asset('assets/images/ywda_admin_logo.png', scale: 30),
        Text('YOUTH DEVELOPMENT AFFAIRS',
            style: GoogleFonts.poppins(textStyle: whiteBoldStyle())),
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

AppBar orgAppBarWidget(BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        Image.asset('assets/images/ywda_admin_logo.png', scale: 30),
        Text('YOUTH DEVELOPMENT AFFAIRS',
            style: GoogleFonts.poppins(textStyle: whiteBoldStyle())),
      ],
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
            onPressed: () => GoRouter.of(context).go('/editOwnOrgHead'),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 88, 147, 201),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: Text('Account',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w800))),
      )
    ],
  );
}

AppBar loginAppBar(BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: MediaQuery.of(context).size.height * 0.08,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset('assets/images/ywda_admin_logo.png', scale: 30),
            Gap(10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YDA',
                    style: GoogleFonts.poppins(textStyle: whiteBoldStyle())),
                Text('LAGUNA',
                    style: GoogleFonts.poppins(textStyle: yellowBoldStyle()))
              ],
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: TextButton(
                  onPressed: () => GoRouter.of(context).go('/login'),
                  child: Text('Login',
                      textAlign: TextAlign.center,
                      style:
                          GoogleFonts.poppins(textStyle: yellowBoldStyle()))),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: TextButton(
                  onPressed: () {},
                  child: Text('Home',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(textStyle: whiteThinStyle()))),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: TextButton(
                  onPressed: () {},
                  child: Text('About Us',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(textStyle: whiteThinStyle()))),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: TextButton(
                  onPressed: () {},
                  child: Text('Programs & \n Services',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(textStyle: whiteThinStyle()))),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: TextButton(
                  onPressed: () {},
                  child: Text('Event \n Updates',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(textStyle: whiteThinStyle()))),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: TextButton(
                  onPressed: () {},
                  child: Text('Forms',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(textStyle: whiteThinStyle()))),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: TextButton(
                  onPressed: () {},
                  child: Text('About Us',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(textStyle: whiteThinStyle()))),
            ),
          ],
        )
      ],
    ),
  );
}
