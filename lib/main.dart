import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:ywda_dashboard/screens/add_announcement_screen.dart';
import 'package:ywda_dashboard/screens/add_form_screen.dart';
import 'package:ywda_dashboard/screens/add_org_screen.dart';
import 'package:ywda_dashboard/screens/add_project_screen.dart';
import 'package:ywda_dashboard/screens/admin_settings_screen.dart';
import 'package:ywda_dashboard/screens/edit_announcement_screen.dart';
import 'package:ywda_dashboard/screens/edit_org_screen.dart';
import 'package:ywda_dashboard/screens/edit_project_screen.dart';
import 'package:ywda_dashboard/screens/grade_submission_screen.dart';
import 'package:ywda_dashboard/screens/home_screen.dart';
import 'package:ywda_dashboard/screens/log_in_screen.dart';
import 'package:ywda_dashboard/screens/register_screen.dart';
import 'package:ywda_dashboard/screens/view_announcement_screen.dart';
import 'package:ywda_dashboard/screens/view_forms_screen.dart';
import 'package:ywda_dashboard/screens/view_orgs_screen.dart';
import 'package:ywda_dashboard/screens/view_projects_screen.dart';
import 'package:ywda_dashboard/screens/view_submissions_screen.dart';
import 'package:ywda_dashboard/screens/welcome_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _routes = GoRouter(initialLocation: '/', routes: [
    GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
        routes: [
          GoRoute(
            path: 'register',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: const RegisterScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            path: 'login',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: const LogInScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            path: 'home',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: const HomeScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            path: 'orgs',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: const ViewOrgsScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            path: 'orgs/addOrg',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: const AddOrgScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            name: 'editOrg',
            path: 'orgs/edit/:orgID',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: EditOrgScreen(orgID: state.pathParameters['orgID']!),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            path: 'forms',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: const ViewFormsScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            path: 'forms/addForm',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: const AddFormScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            path: 'project',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: const ViewProjectsScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            path: 'project/addProject',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: const AddProjectScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            name: 'editProject',
            path: 'project/edit/:projectID',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: EditProjectScreen(
                      projectID: state.pathParameters['projectID']!),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            path: 'announcement',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: const ViewAnnouncementScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            path: 'announcement/addAnnouncement',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: const AddAnnouncementScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            name: 'editAnnouncement',
            path: 'announcement/edit/:announcementID',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: EditAnnouncementScreen(
                      announcementID: state.pathParameters['announcementID']!),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            path: 'submissions',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: const ViewSubmissionsScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            name: 'gradeSubmissions',
            path: 'submissions/gradeSubmission/:skill/:subskill/:clientID',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: GradeSubmissionScreen(
                    skill: state.pathParameters['skill']!,
                    subSkill: state.pathParameters['subskill']!,
                    clientID: state.pathParameters['clientID']!,
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
          GoRoute(
            path: 'adminSettings',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: const AdminSettingsScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOutCirc)
                            .animate(animation),
                        child: child);
                  });
            },
          ),
        ])
  ]);

  final ThemeData _themeData = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 21, 57, 119)),
      scaffoldBackgroundColor: const Color.fromARGB(255, 227, 236, 244),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color.fromARGB(255, 53, 113, 217),
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: Colors.black,
        backgroundColor: Color.fromARGB(255, 217, 217, 217),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 217, 217, 217),
          unselectedItemColor: Colors.black,
          selectedItemColor: Color.fromARGB(255, 53, 113, 217)),
      listTileTheme: const ListTileThemeData(
          iconColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              shape: MaterialStateProperty.all<OutlinedBorder>(
                  const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadiusDirectional.all(Radius.circular(10)))),
              backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 53, 113, 217)))));

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        routerConfig: _routes,
        title: 'Youth Welfare Development Affairs Admin Dashboard',
        theme: _themeData);
  }
}
