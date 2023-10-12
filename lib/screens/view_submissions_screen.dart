import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

class ViewSubmissionsScreen extends StatefulWidget {
  const ViewSubmissionsScreen({super.key});

  @override
  State<ViewSubmissionsScreen> createState() => _ViewSubmissionsScreenState();
}

class _ViewSubmissionsScreenState extends State<ViewSubmissionsScreen> {
  bool _isLoading = true;
  bool _alreadyInitialized = false;
  List<Map<dynamic, dynamic>> allSubmissions = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllUsers();
  }

  Future getAllUsers() async {
    if (_alreadyInitialized == true) {
      return;
    }
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'CLIENT')
          .get();
      final userDocs = users.docs;
      for (final doc in userDocs) {
        Map<dynamic, dynamic> userData = doc.data();
        if (!userData.containsKey('skillsDeveloped')) {
          continue;
        }
        Map<dynamic, dynamic> skillsDeveloped = userData['skillsDeveloped'];
        for (final skill in skillsDeveloped.keys) {
          Map<dynamic, dynamic> thisSkill = skillsDeveloped[skill];
          for (final subskill in thisSkill.keys) {
            Map<dynamic, dynamic> thisSubskill = thisSkill[subskill];
            if (thisSubskill['status'] == 'PENDING') {
              allSubmissions.add({
                'clientID': doc.id,
                'name': userData['fullName'],
                'skill': skill,
                'subskill': subskill
              });
            }
          }
        }
      }
      setState(() {
        _alreadyInitialized = true;
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all users: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
        body: Row(
          children: [
            leftNavigator(context, 7),
            bodyWidgetWhiteBG(
                context,
                switchedLoadingContainer(
                    _isLoading,
                    horizontalPadding5Percent(
                        context,
                        verticalPadding5Percent(
                            context, _formsContainerWidget()))))
          ],
        ));
  }

  Widget _formsContainerWidget() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(children: [
        _submissionLabelRow(),
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: allSubmissions.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: allSubmissions.length,
                    itemBuilder: (context, index) {
                      double rowHeight = 50;
                      Map<dynamic, dynamic> submissionData =
                          allSubmissions[index];
                      Color entryTextColor =
                          index % 2 == 0 ? Colors.black : Colors.white;

                      Color entryBackgroundColor =
                          index % 2 == 0 ? Colors.white : Colors.grey;
                      Color entryBorderColor =
                          index % 2 != 0 ? Colors.white : Colors.grey;
                      print('ENTRY $index: ${allSubmissions[index]}');
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          color: entryBackgroundColor,
                        ),
                        child: Row(
                          children: [
                            Flexible(
                                flex: 1,
                                child: Container(
                                  height: rowHeight,
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: entryBorderColor)),
                                  child: Center(
                                      child: AutoSizeText('${index + 1}',
                                          style: _submissionEntryStyle(
                                              entryTextColor))),
                                )),
                            Flexible(
                              flex: 2,
                              child: Container(
                                height: rowHeight,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: entryBorderColor)),
                                child: Center(
                                    child: AutoSizeText(submissionData['name'],
                                        style: _submissionEntryStyle(
                                            entryTextColor))),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                height: rowHeight,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: entryBorderColor)),
                                child: Center(
                                    child: AutoSizeText(submissionData['skill'],
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: _submissionEntryStyle(
                                            entryTextColor))),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                height: rowHeight,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: entryBorderColor)),
                                child: Center(
                                    child: AutoSizeText(
                                        submissionData['subskill'],
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: _submissionEntryStyle(
                                            entryTextColor))),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                height: rowHeight,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: entryBorderColor)),
                                child: Center(
                                    child: ElevatedButton(
                                  onPressed: () {
                                    GoRouter.of(context).goNamed(
                                        'gradeSubmissions',
                                        pathParameters: {
                                          'skill': submissionData['skill'],
                                          'subskill':
                                              submissionData['subskill'],
                                          'clientID': submissionData['clientID']
                                        });
                                  },
                                  child: AutoSizeText('VIEW ENTRY',
                                      style: GoogleFonts.inter(
                                          textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 23,
                                              fontWeight: FontWeight.bold))),
                                )),
                              ),
                            )
                          ],
                        ),
                      );
                    })
                : _noSubmissionsAvailableWidget())
      ]),
    );
  }

  Widget _submissionLabelRow() {
    double rowHeight = 50;
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: Colors.grey,
      ),
      child: Row(
        children: [
          Flexible(
              flex: 1,
              child: Container(
                height: rowHeight,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.white)),
                child: Center(
                    child: AutoSizeText('#',
                        style: _submissionEntryStyle(Colors.white))),
              )),
          Flexible(
            flex: 2,
            child: Container(
              height: rowHeight,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Center(
                  child: AutoSizeText('Name',
                      style: _submissionEntryStyle(Colors.white))),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              height: rowHeight,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Center(
                  child: AutoSizeText('Skill',
                      style: _submissionEntryStyle(Colors.white))),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              height: rowHeight,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Center(
                  child: AutoSizeText('Subskill',
                      style: _submissionEntryStyle(Colors.white))),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              height: rowHeight,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Center(
                  child: AutoSizeText('View Entry',
                      style: _submissionEntryStyle(Colors.white))),
            ),
          )
        ],
      ),
    );
  }

  Widget _noSubmissionsAvailableWidget() {
    return Center(
      child: Text(
        'NO FORMS AVAILABLE',
        style: GoogleFonts.poppins(
            textStyle: const TextStyle(
                fontSize: 38,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  TextStyle _submissionEntryStyle(Color thisColor) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
            color: thisColor, fontSize: 23, fontWeight: FontWeight.w400));
  }
}
