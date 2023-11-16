import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/utils/color_util.dart';
import 'package:ywda_dashboard/utils/delete_entry_dialog_util.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_button_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_miscellaneous_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../widgets/custom_text_widgets.dart';

class ViewSubmissionsScreen extends StatefulWidget {
  const ViewSubmissionsScreen({super.key});

  @override
  State<ViewSubmissionsScreen> createState() => _ViewSubmissionsScreenState();
}

class _ViewSubmissionsScreenState extends State<ViewSubmissionsScreen> {
  bool _isLoading = true;
  bool _alreadyInitialized = false;
  List<Map<dynamic, dynamic>> allSubmissions = [];

  int pageNumber = 1;
  int maxPageNumber = 1;

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
      allSubmissions.clear();
      for (final doc in userDocs) {
        final userData = doc.data();
        final personalShield =
            userData['personalShield'] as Map<dynamic, dynamic>;
        final twentyStatements =
            userData['twentyStatements']['entries'] as List<dynamic>;
        bool twentyStatementsComplete = !twentyStatements.contains('');
        print(
            'client ID: ${doc.id} \t statemnt count: ${twentyStatements.length}');
        if (personalShield.length == 6) {
          allSubmissions.add({
            'clientID': doc.id,
            'name': userData['firstName'],
            'parameter': 'personalShield',
            'entries': personalShield,
            'accepted': userData['hasPersonalShieldBadge'],
            'badgeBool': 'hasPersonalShieldBadge'
          });
        }
        if (twentyStatementsComplete && twentyStatements.length == 20) {
          allSubmissions.add({
            'clientID': doc.id,
            'name': userData['firstName'],
            'parameter': 'twentyStatements',
            'entries': twentyStatements,
            'accepted': userData['hasTwentyStatementsBadge'],
            'badgeBool': 'hasTwentyStatementsBadge'
          });
        }
      }
      maxPageNumber = (allSubmissions.length / 10).ceil();

      setState(() {
        _alreadyInitialized = true;
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all users: $error')));
    }
  }

  void toggleBadge(
      String youthID, String hasBadgeParameter, bool badgeBool) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(youthID)
          .update({hasBadgeParameter: !badgeBool});
      _alreadyInitialized = false;
      getAllUsers();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error granting badge: $error')));
      setState(() {
        _isLoading = false;
      });
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
                    SingleChildScrollView(
                        child: allPadding5Percent(
                            context, _submissionsContainerWidget()))))
          ],
        ));
  }

  Widget _submissionsContainerWidget() {
    return Column(
      children: [
        viewContentContainer(context,
            child: Column(
              children: [
                _submissionLabelRow(),
                allSubmissions.isNotEmpty
                    ? _submissionEntries()
                    : viewContentUnavailable(context,
                        text: 'NO SUBMISSIONS AVAILABLE')
              ],
            )),
        if (allSubmissions.length > 10) _navigatorButtons()
      ],
    );
  }

  Widget _submissionLabelRow() {
    return viewContentLabelRow(
      context,
      children: [
        viewFlexTextCell('#',
            flex: 1,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Name',
            flex: 2,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Assessment Skill',
            flex: 2,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('View Entry',
            flex: 2,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white)
      ],
    );
  }

  Widget _submissionEntries() {
    return SizedBox(
      height: 500,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount:
              pageNumber == maxPageNumber ? allSubmissions.length % 10 : 10,
          itemBuilder: (context, index) {
            Map<dynamic, dynamic> submissionData =
                allSubmissions[index + ((pageNumber - 1) * 10)];
            Color entryColor = index % 2 == 0 ? Colors.black : Colors.white;
            Color backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey;
            Color borderColor = index % 2 == 0 ? Colors.grey : Colors.white;
            return viewContentEntryRow(context,
                children: [
                  viewFlexTextCell('#${(index + 1) + ((pageNumber - 1) * 10)}',
                      flex: 1,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(submissionData['name'],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(
                      submissionData['parameter'] == 'personalShield'
                          ? 'PERSONAL SHIELD'
                          : 'TWENTY STATEMENTS',
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexActionsCell([
                    viewEntryPopUpButton(context, onPress: () {
                      if (submissionData['parameter'] == 'personalShield') {
                        showPersonalShieldDialog(submissionData['entries']);
                      } else {
                        showTwentyStatementsDialog(submissionData['entries']);
                      }
                    }),
                    if (submissionData['accepted'])
                      revokeBadgeButton(context, onPress: () {
                        displayDeleteEntryDialog(context,
                            message:
                                'Are you sure you want to revoke this youth\'s badge?',
                            deleteWord: 'Revoke',
                            deleteEntry: () => toggleBadge(
                                submissionData['clientID'],
                                submissionData['badgeBool'],
                                submissionData['accepted']));
                      })
                    else
                      grantBadgeButton(context,
                          onPress: () => toggleBadge(
                              submissionData['clientID'],
                              submissionData['badgeBool'],
                              submissionData['accepted']))
                  ],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor)
                ],
                borderColor: borderColor,
                isLastEntry: index == allSubmissions.length - 1);
          }),
    );
  }

  Widget _navigatorButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
          width: MediaQuery.of(context).size.height * 0.6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              previousPageButton(context,
                  onPress: pageNumber == 1
                      ? null
                      : () {
                          if (pageNumber == 1) {
                            return;
                          }
                          setState(() {
                            pageNumber--;
                          });
                        }),
              AutoSizeText(pageNumber.toString(), style: blackBoldStyle()),
              nextPageButton(context,
                  onPress: pageNumber == maxPageNumber
                      ? null
                      : () {
                          if (pageNumber == maxPageNumber) {
                            return;
                          }
                          setState(() {
                            pageNumber++;
                          });
                        })
            ],
          )),
    );
  }

  void showPersonalShieldDialog(Map<dynamic, dynamic> shieldEntries) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(children: [
                  AutoSizeText('PERSONAL SHIELD ENTRIES',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 50)),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _shieldSectionEntry('Best Compliment',
                                  shieldEntries['bestCompliment']['imageURL']),
                              _shieldSectionEntry('Favorite People',
                                  shieldEntries['favoritePeople']['imageURL']),
                              _shieldSectionEntry(
                                  'My Greatest Character Strength',
                                  shieldEntries['myGreatestCharacterStrength']
                                      ['imageURL'])
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _shieldSectionEntry(
                                  'Something I Do Well',
                                  shieldEntries['somethingIDoWell']
                                      ['imageURL']),
                              _shieldSectionEntry(
                                  'What Makes Me Unique',
                                  shieldEntries['whatMakesMeUnique']
                                      ['imageURL']),
                              _shieldSectionEntry(
                                  'Worst Character Flaw',
                                  shieldEntries['worstCharacterFlaw']
                                      ['imageURL'])
                            ],
                          )
                        ],
                      )),
                  Gap(40),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    height: 40,
                    child: ElevatedButton(
                        onPressed: () => GoRouter.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.veniceBlue),
                        child: AutoSizeText('CLOSE')),
                  )
                ]),
              ),
            ));
  }

  void showTwentyStatementsDialog(List<dynamic> statements) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.8,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AutoSizeText('TWENTY STATMENT ENTRIES',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 50)),
                      Gap(20),
                      Column(
                          children: statements.map((statement) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: AutoSizeText('I am $statement',
                              style: GoogleFonts.poppins()),
                        );
                      }).toList()),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: 40,
                        child: ElevatedButton(
                            onPressed: () => GoRouter.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.veniceBlue),
                            child: AutoSizeText('CLOSE')),
                      )
                    ],
                  ),
                ))));
  }

  Widget _shieldSectionEntry(String label, String url) {
    return Column(children: [
      AutoSizeText(label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      Container(
        width: MediaQuery.of(context).size.width * 0.15,
        height: MediaQuery.of(context).size.height * 0.25,
        decoration:
            BoxDecoration(border: Border.all(width: 2), color: Colors.black),
        child: Image.network(url),
      )
    ]);
  }
}
