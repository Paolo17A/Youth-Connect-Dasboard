import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:ywda_dashboard/utils/color_util.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../widgets/custom_miscellaneous_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  bool _doneInitializing = false;
  List<DocumentSnapshot> allUsers = [];
  int inSchool = 0;
  int outSchool = 0;
  int laborForce = 0;
  Map<String, double> ageMap = {
    'CHILD YOUTH': 0,
    'CORE YOUTH': 0,
    'ADULT YOUTH': 0
  };
  /*Map<String, double> civilStatusMap = {
    'SINGLE': 0,
    'MARRIED': 0,
    'DIVORCED': 0,
    'SINGLE-PARENTS': 0,
    'WIDOWED': 0,
    'SEPARATE': 0
  };*/
  Map<String, double> genderMap = {
    'WOMAN': 0,
    'MAN': 0,
    'NON-BINARY': 0,
    'TRANSGENDER': 0,
    'INTERSEX': 0,
    'OTHERS': 0
  };
  List<DocumentSnapshot> allOrgs = [];
  List<String> allTowns = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeHome();
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  void initializeHome() async {
    if (_doneInitializing) {
      return;
    }
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'CLIENT')
          .get();
      allUsers = users.docs;

      Map<dynamic, dynamic> userData;
      String education;
      String gender;
      int age;
      for (var user in allUsers) {
        userData = (user.data() as Map<dynamic, dynamic>);
        if (userData.containsKey('categoryGeneral')) {
          education = userData['categoryGeneral'];
          if (education == 'IN SCHOOL') {
            inSchool++;
          } else if (education == 'OUT OF SCHOOL') {
            outSchool++;
          } else if (education == 'LABOR FORCE') {
            laborForce++;
          }
        }

        if (userData.containsKey('gender')) {
          gender = userData['gender'];
          if (gender == 'WOMAN') {
            genderMap['WOMAN'] = genderMap['WOMAN']! + 1;
          } else if (gender == 'MAN') {
            genderMap['MAN'] = genderMap['MAN']! + 1;
          } else if (gender == 'NON-BINARY') {
            genderMap['NON-BINARY'] = genderMap['NON-BINARY']! + 1;
          } else if (gender == 'TRANSGENDER') {
            genderMap['TRANSGENDER'] = genderMap['TRANSGENDER']! + 1;
          } else if (gender == 'INTERSEX') {
            genderMap['INTERSEX'] = genderMap['INTERSEX']! + 1;
          } else {
            genderMap['OTHERS'] = genderMap['OTHERS']! + 1;
          }
        }

        if (userData.containsKey('birthday')) {
          age = _calculateAge((userData['birthday'] as Timestamp).toDate());
          if (age >= 15 && age <= 17) {
            ageMap['CHILD YOUTH'] = ageMap['CHILD YOUTH']! + 1;
          } else if (age >= 18 && age <= 24) {
            ageMap['CORE YOUTH'] = ageMap['CORE YOUTH']! + 1;
          } else if (age >= 25 && age <= 30) {
            ageMap['ADULT YOUTH'] = ageMap['ADULT YOUTH']! + 1;
          }
        }

        if (userData.containsKey('city') &&
            !allTowns.contains(userData['city'].toString().trim())) {
          allTowns.add(userData['city'].toString().trim());
        }
      }

      setState(() {
        _isLoading = false;
        _doneInitializing = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error initializing home screen: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
        body: Row(
          children: [
            leftNavigator(context, 0),
            bodyWidgetWhiteBG(
                context,
                switchedLoadingContainer(
                    _isLoading,
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Column(
                          children: [
                            _analyticsBreakdown(),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03),
                            horizontalPadding3Percent(
                                context,
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _educationBreakdown(),
                                      _youthBreakdown(),
                                      _genderBreakdown()
                                    ]))
                          ],
                        ),
                      ),
                    )))
          ],
        ));
  }

  Widget _analyticsBreakdown() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.04,
          horizontal: MediaQuery.of(context).size.width * 0.03,
        ),
        child: Wrap(
          spacing: MediaQuery.of(context).size.width * 0.01,
          runSpacing: MediaQuery.of(context).size.height * 0.02,
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.spaceEvenly,
          children: [
            analyticReportWidget(context,
                count: inSchool.toString(),
                demographic: 'In School',
                displayIcon:
                    Image.asset('assets/images/icons/in school.png', scale: 2),
                onPress: () {
              GoRouter.of(context).goNamed('youthInformation',
                  pathParameters: {'category': 'EDUCATION'});
            }),
            analyticReportWidget(context,
                count: inSchool.toString(),
                demographic: 'Out of School',
                displayIcon: Image.asset(
                    'assets/images/icons/out of school.png',
                    scale: 2), onPress: () {
              GoRouter.of(context).goNamed('youthInformation',
                  pathParameters: {'category': 'EDUCATION'});
            }),
            analyticReportWidget(context,
                count: laborForce.toString(),
                demographic: 'Labor Force',
                displayIcon: Image.asset('assets/images/icons/forced labor.png',
                    scale: 2), onPress: () {
              GoRouter.of(context).goNamed('youthInformation',
                  pathParameters: {'category': 'EDUCATION'});
            }),
            analyticReportWidget(context,
                count: allUsers.length.toString(),
                demographic: 'Total Users',
                displayIcon:
                    Image.asset('assets/images/icons/user.png', scale: 2),
                onPress: () {
              GoRouter.of(context).go('/users');
            }),
            analyticReportWidget(context,
                count: allOrgs.length.toString(),
                demographic: 'Total Organizations',
                displayIcon: Image.asset('assets/images/icons/organization.png',
                    scale: 2), onPress: () {
              GoRouter.of(context).go('/orgs');
            }),
            analyticReportWidget(context,
                count: allTowns.length.toString(),
                demographic: 'Towns',
                displayIcon:
                    Image.asset('assets/images/icons/town.png', scale: 2),
                onPress: () {
              GoRouter.of(context).goNamed('youthInformation',
                  pathParameters: {'category': 'TOWN'});
            }),
            analyticReportWidget(context,
                count: '',
                demographic: 'Age Report',
                displayIcon:
                    Image.asset('assets/images/icons/age.png', scale: 2),
                onPress: () {
              GoRouter.of(context).go('/ageReport');
            }),
            analyticReportWidget(context,
                count: '',
                demographic: 'Gender Report',
                displayIcon:
                    Image.asset('assets/images/icons/gender.png', scale: 2),
                onPress: () {
              GoRouter.of(context).go('/genderReport');
            }),
          ],
        ),
      ),
    );
  }

  Widget _educationBreakdown() {
    return breakdownContainer(
      context,
      child: Column(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          child: Row(
            children: [
              AutoSizeText(
                'Education',
                style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 40)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              percentBarWidget(context, CustomColors.darkBlue,
                  (inSchool / allUsers.length), 'In School'),
              percentBarWidget(context, CustomColors.darkBlue,
                  (outSchool / allUsers.length), 'Out of School'),
              percentBarWidget(context, CustomColors.darkBlue,
                  (laborForce / allUsers.length), 'Labor Force')
            ],
          ),
        )
      ]),
    );
  }

  Widget _youthBreakdown() {
    return breakdownContainer(context,
        child: Column(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
            child: Row(
              children: [
                AutoSizeText(
                  'Youth Category',
                  style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 40)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          PieChart(
              dataMap: ageMap,
              colorList: [
                Colors.yellow,
                Colors.deepOrange,
                const Color.fromARGB(255, 240, 207, 159)
              ],
              chartValuesOptions: const ChartValuesOptions(decimalPlaces: 0))
        ]));
  }

  Widget _genderBreakdown() {
    return breakdownContainer(context,
        child: Column(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
            child: Row(
              children: [
                AutoSizeText(
                  'Gender Report',
                  overflow: TextOverflow.clip,
                  style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 40)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          PieChart(
              dataMap: genderMap,
              colorList: [
                Colors.redAccent,
                Colors.orangeAccent,
                Colors.yellowAccent,
                Colors.greenAccent,
                Colors.blueAccent,
                Colors.purpleAccent
              ],
              chartValuesOptions: const ChartValuesOptions(decimalPlaces: 0))
        ]));
  }
}
