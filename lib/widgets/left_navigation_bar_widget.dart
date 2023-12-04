import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ywda_dashboard/utils/color_util.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_text_widgets.dart';

import '../utils/go_router_util.dart';

Widget leftNavigator(BuildContext context, double index) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      color: CustomColors.balticSea,
      child: allPadding20Pix(
        Column(children: [
          Flexible(
              flex: 1,
              child: ListView(padding: EdgeInsets.zero, children: [
                Container(
                    decoration: BoxDecoration(
                        color: index == 0 ? CustomColors.softBlue : null,
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                        title: Text('Dashboard', style: whiteThinStyle()),
                        onTap: () => GoRouter.of(context).go('/home'))),
                Container(
                    decoration: BoxDecoration(
                        color: index == 4 ? CustomColors.softBlue : null,
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                        title: Text('User Accounts', style: whiteThinStyle()),
                        onTap: () => GoRouter.of(context).go('/users'))),
                Container(
                    decoration: BoxDecoration(
                        color: index == 3 ? CustomColors.softBlue : null,
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                        title: Text('Forms', style: whiteThinStyle()),
                        onTap: () => GoRouter.of(context).go('/forms'))),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _whiteLine(),
                  horizontalPadding5pix(AutoSizeText('Youth Management',
                      style: whiteThinStyle(size: 12))),
                  _whiteLine()
                ]),
                Container(
                    decoration: BoxDecoration(
                        color: index == 1 ? CustomColors.softBlue : null,
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                        title: Text(
                          'Youth Information',
                          style: whiteThinStyle(),
                        ),
                        onTap: () =>
                            GoRouter.of(context).goNamed('youthInformation'))),
                Container(
                    decoration: BoxDecoration(
                        color: index == 1.1 ? CustomColors.softBlue : null,
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                        title: Text('Age Report', style: whiteThinStyle()),
                        onTap: () => GoRouter.of(context).go('/ageReport'))),
                Container(
                    decoration: BoxDecoration(
                        color: index == 1.2 ? CustomColors.softBlue : null,
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                        title: Text('Gender Report', style: whiteThinStyle()),
                        onTap: () => GoRouter.of(context).go('/genderReport'))),
                Container(
                    decoration: BoxDecoration(
                        color: index == 1.3 ? CustomColors.softBlue : null,
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                        title: Text('Towns', style: whiteThinStyle()),
                        onTap: () =>
                            GoRouter.of(context).goNamed(GoRoutes.townReport))),
                Container(
                    decoration: BoxDecoration(
                        color: index == 5 ? CustomColors.softBlue : null,
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                        title: Text('Projects', style: whiteThinStyle()),
                        onTap: () => GoRouter.of(context).go('/project'))),
                Container(
                    decoration: BoxDecoration(
                        color: index == 7 ? CustomColors.softBlue : null,
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                        title: Text('Tasks', style: whiteThinStyle()),
                        onTap: () => GoRouter.of(context).go('/submissions'))),
                Container(
                    decoration: BoxDecoration(
                        color: index == 8 ? CustomColors.softBlue : null,
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                        title: Text('FAQs', style: whiteThinStyle()),
                        onTap: () => GoRouter.of(context).go('/faqs'))),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _whiteLine(),
                  horizontalPadding5pix(AutoSizeText('Organizations Management',
                      style: whiteThinStyle(size: 12))),
                  _whiteLine()
                ]),
                Container(
                    decoration: BoxDecoration(
                        color: index == 2 ? CustomColors.softBlue : null,
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                        title: Text('Organizations', style: whiteThinStyle()),
                        onTap: () => GoRouter.of(context).go('/orgHeads'))),
                Container(
                    decoration: BoxDecoration(
                        color: index == 2.1 ? CustomColors.softBlue : null,
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                        title: Text('Renewal', style: whiteThinStyle()),
                        onTap: () => GoRouter.of(context).go('/orgRenewals'))),
                Container(
                    decoration: BoxDecoration(
                        color: index == 2.2 ? CustomColors.softBlue : null,
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                        title: Text('Profiles', style: whiteThinStyle()),
                        onTap: () => GoRouter.of(context).go('/orgs'))),
                Container(
                    decoration: BoxDecoration(
                        color: index == 6 ? CustomColors.softBlue : null,
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                        title: Text('Announcements', style: whiteThinStyle()),
                        onTap: () => GoRouter.of(context).go('/announcement'))),
              ])),
        ]),
      ));
}

Widget orgLeftNavigator(BuildContext context, String section) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      color: CustomColors.balticSea,
      child: allPadding20Pix(
        Column(children: [
          Flexible(
              flex: 1,
              child: ListView(padding: EdgeInsets.zero, children: [
                allPadding4pix(
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: section == GoRoutes.orgHome
                              ? CustomColors.softBlue
                              : null),
                      child: ListTile(
                          title: Text('Dashboard', style: whiteThinStyle()),
                          onTap: () =>
                              GoRouter.of(context).goNamed(GoRoutes.orgHome))),
                ),
                allPadding4pix(
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: section == GoRoutes.orgRenewalHistory
                              ? CustomColors.softBlue
                              : null),
                      child: ListTile(
                          title: Text(
                            'Org Renewal',
                            style: whiteThinStyle(),
                          ),
                          onTap: () => GoRouter.of(context)
                              .goNamed(GoRoutes.orgRenewalHistory))),
                ),
                allPadding4pix(
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: section == GoRoutes.orgProjects
                              ? CustomColors.softBlue
                              : null),
                      child: ListTile(
                          title: Text('Projects', style: whiteThinStyle()),
                          onTap: () => GoRouter.of(context)
                              .goNamed(GoRoutes.orgProjects))),
                ),
                allPadding4pix(
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: section == GoRoutes.orgProfile
                              ? CustomColors.softBlue
                              : null),
                      child: ListTile(
                          title: Text('Profile', style: whiteThinStyle()),
                          onTap: () => GoRouter.of(context)
                              .goNamed(GoRoutes.orgProfile))),
                ),
              ])),
          ListTile(
              leading: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              title: Text('Log Out', style: whiteThinStyle()),
              onTap: () {
                FirebaseAuth.instance.signOut().then((value) {
                  GoRouter.of(context).goNamed(GoRoutes.login);
                });
              })
        ]),
      ));
}

Widget _whiteLine() {
  return Flexible(
      child: Container(
          height: 2,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10))));
}
