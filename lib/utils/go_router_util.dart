import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoRoutes {
  //  Universal
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';

  //  Admin
  static const String home = 'home';
  static const String youthInformation = 'youthInformation';
  static const String adminSettings = 'adminSettings';

  //  Org Head
  static const String orgHome = 'orgHome';
  static const String orgRenewalHistory = 'orgRenewalHistory';
  static const String orgProjects = 'orgProjects';
  static const String addOrgProject = 'addOrgProject';
  static const String editOrgProject = 'editOrgProject';
  static const String orgProfile = 'orgProfile';
  static const String editOwnOrgHead = 'editOwnOrgHead';
}

CustomTransitionPage customTransition(
    BuildContext context, GoRouterState state, Widget widget) {
  return CustomTransitionPage(
      fullscreenDialog: true,
      key: state.pageKey,
      child: widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return easeInOutCircTransition(animation, child);
      });
}

FadeTransition easeInOutCircTransition(
    Animation<double> animation, Widget child) {
  return FadeTransition(
      opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
      child: child);
}
