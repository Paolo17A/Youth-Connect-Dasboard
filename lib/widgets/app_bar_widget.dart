import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/utils/go_router_util.dart';
import 'package:ywda_dashboard/widgets/custom_text_widgets.dart';

AppBar appBarWidget(BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Colors.white,
    title: Row(
      children: [
        Image.asset('assets/images/ywda_admin_logo.png', scale: 30),
        Text('YOUTH DEVELOPMENT AFFAIRS',
            style: GoogleFonts.poppins(textStyle: blackBoldStyle())),
      ],
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Transform.scale(
          scale: 2,
          child: IconButton(
              onPressed: () =>
                  GoRouter.of(context).goNamed(GoRoutes.adminSettings),
              icon: Icon(Icons.account_circle_outlined)),
        ),
      )
    ],
  );
}

AppBar orgAppBarWidget(BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Colors.white,
    title: Row(
      children: [
        Image.asset('assets/images/ywda_admin_logo.png', scale: 30),
        Text('YOUTH DEVELOPMENT AFFAIRS',
            style: GoogleFonts.poppins(textStyle: blackBoldStyle())),
      ],
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Transform.scale(
          scale: 2,
          child: IconButton(
              onPressed: () => GoRouter.of(context).go('/editOwnOrgHead'),
              icon: Icon(Icons.account_circle_outlined)),
        ),
      )
    ],
  );
}

AppBar loginAppBar(BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: MediaQuery.of(context).size.height * 0.08,
    title: Row(
      children: [
        Image.asset('assets/images/ywda_admin_logo.png', scale: 30),
        Gap(10),
        Text('YDA ', style: GoogleFonts.poppins(textStyle: whiteBoldStyle())),
        Text('LAGUNA',
            style: GoogleFonts.poppins(textStyle: yellowBoldStyle())),
      ],
    ),
    actions: [
      TextButton(
          onPressed: () {},
          child: Text('Go To Website', style: whiteBoldStyle()))
    ],
  );
}
