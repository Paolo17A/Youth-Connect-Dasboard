import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
        body: Row(
          children: [
            leftNavigator(context, 7),
            bodyWidgetWhiteBG(
                context,
                switchedLoadingContainer(_isLoading,
                    allPadding5Percent(context, _submissionsContainerWidget())))
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
        viewFlexTextCell('Skill',
            flex: 2,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Subskill',
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
      height: MediaQuery.of(context).size.height * 0.52,
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
                  viewFlexTextCell(submissionData['skill'],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(submissionData['subskill'],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexActionsCell([
                    Center(child: viewEntryButton(() {
                      GoRouter.of(context)
                          .goNamed('gradeSubmissions', pathParameters: {
                        'skill': submissionData['skill'],
                        'subskill': submissionData['subskill'],
                        'clientID': submissionData['clientID']
                      });
                    }))
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
    return SizedBox(
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
        ));
  }
}
