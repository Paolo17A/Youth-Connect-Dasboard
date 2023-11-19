import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ywda_dashboard/utils/color_util.dart';
import 'package:ywda_dashboard/widgets/custom_text_widgets.dart';

Widget leftNavigator(BuildContext context, double index) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      color: CustomColors.softBlue,
      child: Column(children: [
        Flexible(
            flex: 1,
            child: ListView(padding: EdgeInsets.zero, children: [
              Container(
                  color: index == 0 ? Colors.white : null,
                  child: ListTile(
                      title: Text('Dashboard', style: blackBoldStyle()),
                      onTap: () => GoRouter.of(context).go('/home'))),
              Container(
                  color: index == 1 ? Colors.white : null,
                  child: ListTile(
                      title: Text(
                        'Youth Information',
                        style: blackBoldStyle(),
                      ),
                      onTap: () => GoRouter.of(context).goNamed(
                          'youthInformation',
                          pathParameters: {'category': 'NO FILTER'}))),
              Container(
                  color: index == 1.1 ? Colors.white : null,
                  child: ListTile(
                      title: Text('\t\t\tAge Report', style: blackThinStyle()),
                      onTap: () => GoRouter.of(context).go('/ageReport'))),
              Container(
                  color: index == 1.2 ? Colors.white : null,
                  child: ListTile(
                      title:
                          Text('\t\t\Gender Report', style: blackThinStyle()),
                      onTap: () => GoRouter.of(context).go('/genderReport'))),
              Container(
                  color: index == 2 ? Colors.white : null,
                  child: ListTile(
                      title: Text('Organizations', style: blackBoldStyle()),
                      onTap: () => GoRouter.of(context).go('/orgHeads'))),
              Container(
                  color: index == 2.1 ? Colors.white : null,
                  child: ListTile(
                      title:
                          Text('\t\t\tOrg. Renewal', style: blackThinStyle()),
                      onTap: () => GoRouter.of(context).go('/orgRenewals'))),
              Container(
                  color: index == 2.2 ? Colors.white : null,
                  child: ListTile(
                      title:
                          Text('\t\t\tOrg. Profiles', style: blackThinStyle()),
                      onTap: () => GoRouter.of(context).go('/orgs'))),
              /*Container(
                  color: index == 3 ? Colors.white : null,
                  child: ListTile(
                      title: Text('Forms', style: blackBoldStyle()),
                      onTap: () => GoRouter.of(context).go('/forms'))),*/
              Container(
                  color: index == 4 ? Colors.white : null,
                  child: ListTile(
                      title: Text('User Accounts', style: blackBoldStyle()),
                      onTap: () => GoRouter.of(context).go('/users'))),
              Container(
                  color: index == 5 ? Colors.white : null,
                  child: ListTile(
                      title: Text('Projects', style: blackBoldStyle()),
                      onTap: () => GoRouter.of(context).go('/project'))),
              Container(
                  color: index == 6 ? Colors.white : null,
                  child: ListTile(
                      title: Text('Announcements', style: blackBoldStyle()),
                      onTap: () => GoRouter.of(context).go('/announcement'))),
              Container(
                  color: index == 7 ? Colors.white : null,
                  child: ListTile(
                      title: Text('Tasks', style: blackBoldStyle()),
                      onTap: () => GoRouter.of(context).go('/submissions'))),
              Container(
                  color: index == 8 ? Colors.white : null,
                  child: ListTile(
                      title: Text('FAQs', style: blackBoldStyle()),
                      onTap: () => GoRouter.of(context).go('/faqs')))
            ])),
        ListTile(
            leading: const Icon(
              Icons.exit_to_app,
              color: Colors.black,
            ),
            title: Text('Log Out', style: blackBoldStyle()),
            onTap: () {
              FirebaseAuth.instance.signOut().then((value) {
                GoRouter.of(context).go('/login');
              });
            })
      ]));
}

Widget orgLeftNavigator(BuildContext context, int index) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      color: CustomColors.softBlue,
      child: Column(children: [
        Flexible(
            flex: 1,
            child: ListView(padding: EdgeInsets.zero, children: [
              Container(
                  color: index == 0 ? Colors.white : null,
                  child: ListTile(
                      title: Text('Dashboard', style: blackBoldStyle()),
                      onTap: () => GoRouter.of(context).go('/orgHome'))),
              Container(
                  color: index == 1 ? Colors.white : null,
                  child: ListTile(
                      title: Text(
                        'Org Renewal',
                        style: blackBoldStyle(),
                      ),
                      onTap: () =>
                          GoRouter.of(context).go('/orgRenewalHistory'))),
              Container(
                  color: index == 2 ? Colors.white : null,
                  child: ListTile(
                      title: Text('Projects', style: blackBoldStyle()),
                      onTap: () => GoRouter.of(context).go('/orgProjects'))),
              Container(
                  color: index == 3 ? Colors.white : null,
                  child: ListTile(
                      title: Text('Profile', style: blackBoldStyle()),
                      onTap: () => GoRouter.of(context).go('/orgProfile'))),
            ])),
        ListTile(
            leading: const Icon(
              Icons.exit_to_app,
              color: Colors.black,
            ),
            title: Text('Log Out', style: blackBoldStyle()),
            onTap: () {
              FirebaseAuth.instance.signOut().then((value) {
                GoRouter.of(context).go('/login');
              });
            })
      ]));
}
