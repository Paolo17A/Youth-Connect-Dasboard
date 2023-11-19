import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:ywda_dashboard/screens/add_announcement_screen.dart';
import 'package:ywda_dashboard/screens/add_faq_screen.dart';
import 'package:ywda_dashboard/screens/add_form_screen.dart';
import 'package:ywda_dashboard/screens/add_org_head_screen.dart';
import 'package:ywda_dashboard/screens/add_org_project_screen.dart';
import 'package:ywda_dashboard/screens/add_org_screen.dart';
import 'package:ywda_dashboard/screens/add_project_screen.dart';
import 'package:ywda_dashboard/screens/admin_settings_screen.dart';
import 'package:ywda_dashboard/screens/edit_announcement_screen.dart';
import 'package:ywda_dashboard/screens/edit_faq_screen.dart';
import 'package:ywda_dashboard/screens/edit_org_head_screen.dart';
import 'package:ywda_dashboard/screens/edit_org_profile_screen.dart';
import 'package:ywda_dashboard/screens/edit_org_project_screen.dart';
import 'package:ywda_dashboard/screens/edit_org_screen.dart';
import 'package:ywda_dashboard/screens/edit_own_org_head_screen.dart';
import 'package:ywda_dashboard/screens/edit_project_screen.dart';
import 'package:ywda_dashboard/screens/edit_youth_information.dart';
import 'package:ywda_dashboard/screens/forgot_password_screen.dart';
import 'package:ywda_dashboard/screens/grade_submission_screen.dart';
import 'package:ywda_dashboard/screens/home_screen.dart';
import 'package:ywda_dashboard/screens/log_in_screen.dart';
import 'package:ywda_dashboard/screens/org_home_screen.dart';
import 'package:ywda_dashboard/screens/register_screen.dart';
import 'package:ywda_dashboard/screens/view_announcement_screen.dart';
import 'package:ywda_dashboard/screens/view_faqs_screen.dart';
import 'package:ywda_dashboard/screens/view_forms_screen.dart';
import 'package:ywda_dashboard/screens/view_org_projects_screen.dart';
import 'package:ywda_dashboard/screens/view_org_renewals_screen.dart';
import 'package:ywda_dashboard/screens/view_orgs_screen.dart';
import 'package:ywda_dashboard/screens/view_projects_screen.dart';
import 'package:ywda_dashboard/screens/view_renewal_history_screen.dart';
import 'package:ywda_dashboard/screens/view_submissions_screen.dart';
import 'package:ywda_dashboard/screens/view_user_accounts_screen.dart';
import 'package:ywda_dashboard/screens/view_youth_age_report.dart';
import 'package:ywda_dashboard/screens/view_youth_gender_report.dart';
import 'package:ywda_dashboard/screens/view_youth_information.dart';
import 'package:ywda_dashboard/screens/welcome_screen.dart';
import 'package:ywda_dashboard/utils/color_util.dart';
import 'firebase_options.dart';
import 'screens/view_org_heads_screen.dart';
import 'utils/go_router_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _routes = GoRouter(initialLocation: '/login', routes: [
    GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
        routes: [
          GoRoute(
              path: 'register',
              pageBuilder: (context, state) {
                return customTransition(context, state, const RegisterScreen());
              }),
          GoRoute(
              path: 'login',
              pageBuilder: (context, state) {
                return customTransition(context, state, const LogInScreen());
              }),
          GoRoute(
              path: 'forgotPassword',
              pageBuilder: (context, state) {
                return customTransition(
                    context, state, const ForgotPasswordScreen());
              }),
          //ADMIN SCREENS
          GoRoute(
              path: 'home',
              pageBuilder: (context, state) {
                return customTransition(context, state, const HomeScreen());
              }),
          GoRoute(
              path: 'editYouth/:returnPoint/:youthID',
              name: 'editYouth',
              pageBuilder: (context, state) {
                return customTransition(
                    context,
                    state,
                    EditYouthInformationScreen(
                        returnPoint: state.pathParameters['returnPoint']!,
                        youthID: state.pathParameters['youthID']!));
              }),
          GoRoute(
              path: 'youthInformation/:category',
              name: 'youthInformation',
              pageBuilder: (context, state) {
                return customTransition(
                    context,
                    state,
                    ViewYouthInformationScreen(
                        category: state.pathParameters['category']!));
              }),
          GoRoute(
              path: 'ageReport',
              pageBuilder: (context, state) {
                return customTransition(
                    context, state, const ViewYouthAgeReportScreen());
              }),
          GoRoute(
              path: 'genderReport',
              pageBuilder: (context, state) {
                return customTransition(
                    context, state, const ViewYouthGenderReportScreen());
              }),
          GoRoute(
              path: 'orgHeads',
              pageBuilder: (context, state) {
                return customTransition(
                    context, state, const ViewOrgHeadsScreen());
              }),
          GoRoute(
            path: 'orgHeads/add',
            pageBuilder: (context, state) {
              return customTransition(context, state, const AddOrgHeadScreen());
            },
          ),
          GoRoute(
              name: 'editOrgHead',
              path: 'orgHeads/edit/:orgHeadID/:orgID',
              pageBuilder: (context, state) {
                return customTransition(
                    context,
                    state,
                    EditOrgHeadScreen(
                        orgHeadID: state.pathParameters['orgHeadID']!,
                        orgID: state.pathParameters['orgID']!));
              }),
          GoRoute(
              path: 'orgRenewals',
              pageBuilder: (context, state) {
                return customTransition(
                    context, state, const ViewOrgRenewalsScreen());
              }),
          GoRoute(
              path: 'orgs',
              pageBuilder: (context, state) {
                return customTransition(context, state, const ViewOrgsScreen());
              }),
          GoRoute(
            path: 'orgs/addOrg',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  fullscreenDialog: true,
                  key: state.pageKey,
                  child: const AddOrgScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return easeInOutCircTransition(animation, child);
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
                    return easeInOutCircTransition(animation, child);
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
                    return easeInOutCircTransition(animation, child);
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
                    return easeInOutCircTransition(animation, child);
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
                    return easeInOutCircTransition(animation, child);
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
                    return easeInOutCircTransition(animation, child);
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
                    return easeInOutCircTransition(animation, child);
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
                    return easeInOutCircTransition(animation, child);
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
                    return easeInOutCircTransition(animation, child);
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
                    return easeInOutCircTransition(animation, child);
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
                    return easeInOutCircTransition(animation, child);
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
                    return easeInOutCircTransition(animation, child);
                  });
            },
          ),
          GoRoute(
              path: 'users',
              pageBuilder: (context, state) {
                return CustomTransitionPage(
                    fullscreenDialog: true,
                    key: state.pageKey,
                    child: ViewUserAccountsScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return easeInOutCircTransition(animation, child);
                    });
              }),
          GoRoute(
              path: 'faqs',
              pageBuilder: (context, state) {
                return customTransition(context, state, const ViewFAQSscreen());
              }),
          GoRoute(
              path: 'faqs/add',
              pageBuilder: (context, state) {
                return customTransition(context, state, const AddFAQScreen());
              }),
          GoRoute(
              name: 'editFAQ',
              path: 'faqs/edit/:faqID',
              pageBuilder: (context, state) {
                return customTransition(context, state,
                    EditFAQScreen(faqID: state.pathParameters['faqID']!));
              }),
          GoRoute(
              path: 'adminSettings',
              pageBuilder: (context, state) {
                return customTransition(
                    context, state, const AdminSettingsScreen());
              }),
          //  ORG HEAD SCREENS
          GoRoute(
              path: 'orgHome',
              pageBuilder: (context, state) {
                return customTransition(context, state, const OrgHomeScreen());
              }),
          GoRoute(
              path: 'orgRenewalHistory',
              pageBuilder: (context, state) {
                return customTransition(
                    context, state, const ViewRenewalHistoryScreen());
              }),
          GoRoute(
              path: 'orgProjects',
              pageBuilder: (context, state) {
                return customTransition(
                    context, state, const ViewOrgProjectsScreen());
              }),
          GoRoute(
              path: 'orgProjects/add',
              pageBuilder: (context, state) {
                return customTransition(
                    context, state, const AddOrgProjectScreen());
              }),
          GoRoute(
              name: 'editOrgProject',
              path: 'orgProjects/edit/:projectID',
              pageBuilder: (context, state) {
                return customTransition(
                    context,
                    state,
                    EditOrgProjectScreen(
                        projectID: state.pathParameters['projectID']!));
              }),
          GoRoute(
            path: 'editOwnOrgHead',
            pageBuilder: (context, state) {
              return customTransition(
                  context, state, const EditOwnOrgHeadScreen());
            },
          ),
          GoRoute(
              path: 'orgProfile',
              pageBuilder: (context, state) {
                return customTransition(
                    context, state, const EditOrgProfileScreen());
              })
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
        backgroundColor: CustomColors.darkBlue,
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
