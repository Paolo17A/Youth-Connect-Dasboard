import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

Widget leftNavigator(BuildContext context, int index) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      color: const Color.fromARGB(255, 217, 217, 217),
      child: Column(children: [
        Flexible(
          flex: 1,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                color: index == 0 ? Colors.white : null,
                child: ListTile(
                  title: Text('Dashboard', style: _textStyle()),
                  onTap: () {
                    GoRouter.of(context).go('/home');
                  },
                ),
              ),
              Container(
                color: index == 1 ? Colors.white : null,
                child: ListTile(
                  title: Text(
                    'Youth Information',
                    style: _textStyle(),
                  ),
                  onTap: () {
                    //GoRouter.of(context).go('/sections');
                  },
                ),
              ),
              Container(
                color: index == 2 ? Colors.white : null,
                child: ListTile(
                  title: Text('Organizations', style: _textStyle()),
                  onTap: () {
                    GoRouter.of(context).go('/orgs');
                  },
                ),
              ),
              Container(
                color: index == 3 ? Colors.white : null,
                child: ListTile(
                  title: Text('Forms', style: _textStyle()),
                  onTap: () {
                    GoRouter.of(context).go('/forms');
                  },
                ),
              ),
              Container(
                color: index == 4 ? Colors.white : null,
                child: ListTile(
                  title: Text('User Accounts', style: _textStyle()),
                  onTap: () {
                    //GoRouter.of(context).go('/lessons');
                  },
                ),
              ),
              Container(
                color: index == 5 ? Colors.white : null,
                child: ListTile(
                  title: Text('Projects', style: _textStyle()),
                  onTap: () {
                    GoRouter.of(context).go('/project');
                  },
                ),
              ),
              Container(
                color: index == 6 ? Colors.white : null,
                child: ListTile(
                  title: Text('Announcements', style: _textStyle()),
                  onTap: () {
                    GoRouter.of(context).go('/announcement');
                  },
                ),
              ),
              Container(
                color: index == 7 ? Colors.white : null,
                child: ListTile(
                  title: Text('Submissions', style: _textStyle()),
                  onTap: () {
                    //GoRouter.of(context).go('/announcement');
                  },
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(
            Icons.exit_to_app,
            color: Colors.black,
          ),
          title: Text('Log Out', style: _textStyle()),
          onTap: () {
            FirebaseAuth.instance.signOut().then((value) {
              GoRouter.of(context).go('/');
            });
          },
        ),
      ]));
}

TextStyle _textStyle() {
  return GoogleFonts.inter(
      textStyle: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black));
}
