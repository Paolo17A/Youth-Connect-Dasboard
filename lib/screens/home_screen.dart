import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> allUsers = [];

  @override
  void initState() {
    super.initState();
    initializeHome();
  }

  void initializeHome() async {
    try {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'CLIENT')
          .get();
      allUsers = users.docs;
      print('CLIENTS FOUND: ${allUsers.length}');
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing home screen: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  leftNavigator(context, 0),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.75,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color:
                                      const Color.fromARGB(255, 217, 217, 217),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.04,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.03,
                                  ),
                                  child: Wrap(
                                    spacing: MediaQuery.of(context).size.width *
                                        0.01,
                                    runSpacing:
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                    alignment: WrapAlignment.start,
                                    runAlignment: WrapAlignment.spaceEvenly,
                                    children: [
                                      _reportWidget(
                                          context,
                                          0,
                                          'Total Users',
                                          const Icon(Icons.person,
                                              color: Colors.black)),
                                      _reportWidget(
                                          context,
                                          0,
                                          'Organizations',
                                          const Icon(Icons.people,
                                              color: Colors.black)),
                                      _reportWidget(
                                          context,
                                          0,
                                          'Upcoming Events',
                                          const Icon(Icons.local_activity,
                                              color: Colors.black)),
                                      _reportWidget(
                                          context,
                                          0,
                                          'Announcements Made',
                                          const Icon(Icons.announcement_sharp,
                                              color: Colors.black)),
                                      _reportWidget(
                                          context,
                                          0,
                                          'Total Users',
                                          const Icon(Icons.person,
                                              color: Colors.black)),
                                      _reportWidget(
                                          context,
                                          0,
                                          'Organizations',
                                          const Icon(Icons.people,
                                              color: Colors.black)),
                                      _reportWidget(
                                          context,
                                          0,
                                          'Upcoming Events',
                                          const Icon(Icons.local_activity,
                                              color: Colors.black)),
                                      _reportWidget(
                                          context,
                                          0,
                                          'Announcements Made',
                                          const Icon(Icons.announcement_sharp,
                                              color: Colors.black)),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.03),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.03),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      //  EDUCATION
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.23,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: const Color.fromARGB(
                                                255, 217, 217, 217)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(11),
                                          child: Column(children: [
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              child: Row(
                                                children: [
                                                  AutoSizeText(
                                                    'Education',
                                                    style: GoogleFonts.inter(
                                                        textStyle:
                                                            const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 40)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  _percentBarWidget(
                                                      context,
                                                      Colors.blue,
                                                      0.5,
                                                      'In School'),
                                                  _percentBarWidget(
                                                      context,
                                                      Colors.blue,
                                                      0.3,
                                                      'Out of School'),
                                                  _percentBarWidget(
                                                      context,
                                                      Colors.blue,
                                                      0.2,
                                                      'Labor Force')
                                                ],
                                              ),
                                            )
                                          ]),
                                        ),
                                      ),
                                      //YOUTH CATEGORY
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.23,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: const Color.fromARGB(
                                                255, 217, 217, 217)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(11),
                                          child: Column(children: [
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              child: Row(
                                                children: [
                                                  AutoSizeText(
                                                    'Youth Category',
                                                    style: GoogleFonts.inter(
                                                        textStyle:
                                                            const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 40)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  _percentBarWidget(
                                                      context,
                                                      Colors.yellow,
                                                      0.5,
                                                      'Child Youth'),
                                                  _percentBarWidget(
                                                      context,
                                                      Colors.yellow,
                                                      0.3,
                                                      'Core Youth'),
                                                  _percentBarWidget(
                                                      context,
                                                      Colors.yellow,
                                                      0.2,
                                                      'Adult Youth')
                                                ],
                                              ),
                                            )
                                          ]),
                                        ),
                                      ),

                                      //  GENDER REPORT
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.23,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: const Color.fromARGB(
                                                255, 217, 217, 217)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(11),
                                          child: Column(children: [
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              child: Row(
                                                children: [
                                                  AutoSizeText(
                                                    'Gender Report',
                                                    overflow: TextOverflow.clip,
                                                    style: GoogleFonts.inter(
                                                        textStyle:
                                                            const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 40)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ]),
                                        ),
                                      ),
                                    ]),
                              )
                            ],
                          ),
                        ),
                      ))
                ],
              ));
  }

  Widget _reportWidget(
      BuildContext context, int count, String demographic, Icon displayIcon) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
          width: MediaQuery.of(context).size.width * 0.15,
          height: MediaQuery.of(context).size.height * 0.15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
          ),
          child: Row(children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AutoSizeText(count.toString(),
                      maxLines: 2,
                      style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 40)),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: 45,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green),
                    child: Center(
                      child: AutoSizeText(demographic,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
                child: Transform.scale(scale: 2, child: displayIcon))
          ])),
    );
  }

  Widget _percentBarWidget(
      BuildContext context, Color barColor, double percentage, String label) {
    double baseBarWidth = MediaQuery.of(context).size.width * 0.1;
    return Padding(
        padding: const EdgeInsets.all(8),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            width: baseBarWidth,
            child: Stack(
              children: [
                Container(
                  height: 20,
                  width: baseBarWidth,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5)),
                ),
                Container(
                  height: 20,
                  width: baseBarWidth * percentage,
                  color: barColor,
                ),
              ],
            ),
          ),
          SizedBox(
            width: baseBarWidth,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: AutoSizeText('${percentage * 100}%\t $label',
                  maxLines: 2,
                  style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 19))),
            ),
          )
        ]));
  }
}
