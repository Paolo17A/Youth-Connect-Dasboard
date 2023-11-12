import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/delete_entry_dialog_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class ViewOrgHeadsScreen extends StatefulWidget {
  const ViewOrgHeadsScreen({super.key});

  @override
  State<ViewOrgHeadsScreen> createState() => _ViewOrgHeadsScreenState();
}

class _ViewOrgHeadsScreenState extends State<ViewOrgHeadsScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;
  List<DocumentSnapshot> allOrgheads = [];
  Map<String, dynamic> associatedOrgs = {};

  int pageNumber = 1;
  int maxPageNumber = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) getAllOrgHeads();
  }

  void getAllOrgHeads() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final orgHeads = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'ORG HEAD')
          .get();
      allOrgheads = orgHeads.docs;
      maxPageNumber = (allOrgheads.length / 10).ceil();

      associatedOrgs.clear();
      for (var orgHead in allOrgheads) {
        final orgHeadData = orgHead.data() as Map<dynamic, dynamic>;
        final orgID = orgHeadData['organization'];
        if (associatedOrgs.containsKey(orgID)) {
          continue;
        }
        final org = await FirebaseFirestore.instance
            .collection('orgs')
            .doc(orgID)
            .get();
        final orgData = org.data() as Map<dynamic, dynamic>;
        associatedOrgs[orgID] = orgData;
      }

      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all Org Heads: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future revokeOrgAccreditation(String orgID) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    //final goRouter = GoRouter.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('orgs')
          .doc(orgID)
          .update({'isAccredited': false, 'accreditationStatus': ''});
      getAllOrgHeads();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error revoking accreditation: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: orgAppBarWidget(context),
      body: Row(
        children: [
          leftNavigator(context, 2),
          bodyWidgetWhiteBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  horizontalPadding5Percent(
                      context,
                      Column(
                        children: [
                          _newOrgHeadHeaderWidget(),
                          _orgHeadContainerWidget()
                        ],
                      ))))
        ],
      ),
    );
  }

  Widget _newOrgHeadHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        ElevatedButton(
            onPressed: () {
              GoRouter.of(context).go('/orgHeads/add');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 88, 147, 201),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: AutoSizeText('NEW ORGANIZATION',
                  style:
                      GoogleFonts.poppins(textStyle: whiteBoldStyle(size: 18))),
            ))
      ]),
    );
  }

  Widget _orgHeadContainerWidget() {
    return Column(
      children: [
        viewContentContainer(context,
            child: Column(children: [
              _orgHeadLabelRow(),
              associatedOrgs.isNotEmpty
                  ? _orgHeadEntries()
                  : viewContentUnavailable(context,
                      text: 'NO ORGANIZATIONS AVAILABLE')
            ])),
        if (associatedOrgs.length > 10) _navigatorButtons()
      ],
    );
  }

  Widget _orgHeadLabelRow() {
    return viewContentLabelRow(context, children: [
      viewFlexTextCell('#',
          flex: 1,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell('Organization',
          flex: 4,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell('Actions',
          flex: 2,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white)
    ]);
  }

  Widget _orgHeadEntries() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.52,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: pageNumber == maxPageNumber ? allOrgheads.length % 10 : 10,
          itemBuilder: (context, index) {
            final orgHeadData = allOrgheads[index + ((pageNumber - 1) * 10)]
                .data() as Map<dynamic, dynamic>;
            final associatedOrg = associatedOrgs[orgHeadData['organization']]
                as Map<dynamic, dynamic>;
            Color entryColor = index % 2 == 0 ? Colors.black : Colors.white;
            Color backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey;
            Color borderColor = index % 2 == 0 ? Colors.grey : Colors.white;

            return viewContentEntryRow(context,
                children: [
                  viewFlexTextCell('${(index + 1) + ((pageNumber - 1) * 10)}',
                      flex: 1,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(associatedOrg['name'],
                      flex: 4,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexActionsCell([
                    viewEntryPopUpButton(context,
                        onPress: () => _displayOrgDetailsDialog(
                            orgHeadDetails: orgHeadData,
                            orgDetails: associatedOrg)),
                    editEntryButton(context,
                        onPress: () => GoRouter.of(context)
                                .goNamed('editOrgHead', pathParameters: {
                              'orgHeadID':
                                  allOrgheads[index + ((pageNumber - 1) * 10)]
                                      .id,
                              'orgID': orgHeadData['organization']
                            })),
                    if (associatedOrg['isAccredited'] == true)
                      deleteEntryButton(context, onPress: () {
                        displayDeleteEntryDialog(context,
                            message:
                                'Are you sure you want to revoke this organization\'s accreditation?',
                            deleteWord: 'Revoke', deleteEntry: () async {
                          revokeOrgAccreditation(orgHeadData['organization']);
                        });
                      })
                    else
                      SizedBox(width: 50)
                  ],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor)
                ],
                borderColor: borderColor,
                isLastEntry: index == allOrgheads.length - 1);
          }),
    );
  }

  void _displayOrgDetailsDialog(
      {required Map<dynamic, dynamic> orgHeadDetails,
      required Map<dynamic, dynamic> orgDetails}) {
    final orgMembers = orgDetails['members'] as List<dynamic>;
    Timestamp dateEstablishedStamp = orgDetails['dateEstablished'];
    DateTime dateEstablished = dateEstablishedStamp.toDate();
    Timestamp dateApprovedStamp = orgDetails['dateApproved'];
    DateTime dateApproved = dateApprovedStamp.toDate();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: registerBoxContainer(context,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () => GoRouter.of(context).pop(),
                                  child: Text(
                                    'X',
                                    style: blackBoldStyle(),
                                  ))
                            ]),
                        AutoSizeText(
                          'ORGANIZATION NAME',
                          style: blackBoldStyle(),
                        ),
                        Divider(thickness: 2),
                        allPadding20Pix(Column(
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 0.5),
                                    borderRadius: BorderRadius.circular(10)),
                                child: allPadding8Pix(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText('ISLAND: LUZON',
                                        style: blackThinStyle(size: 16)),
                                    AutoSizeText('REGION: Region IV -A',
                                        style: blackThinStyle(size: 16)),
                                    AutoSizeText('PROVINCE: LAGUNA',
                                        style: blackThinStyle(size: 16)),
                                    AutoSizeText(
                                        'MUNICIPALITY: ${orgDetails['municipality']}',
                                        style: blackThinStyle(size: 16)),
                                    AutoSizeText(
                                        'BARANGAY: ${orgDetails['barangay']}',
                                        style: blackThinStyle(size: 16))
                                  ],
                                ))),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 0.5),
                                    borderRadius: BorderRadius.circular(10)),
                                child: allPadding8Pix(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                        'MOBILE / TELEPHONE NUMBER: ${orgDetails['contactDetails']} / ${orgDetails['telephone']}',
                                        style: blackThinStyle(size: 16)),
                                    AutoSizeText(
                                        'ORGANIZATION EMAIL: ${orgDetails['email']}',
                                        style: blackThinStyle(size: 16)),
                                    AutoSizeText(
                                        'NUMBER OF MEMBERS: ${orgMembers.length.toString()}',
                                        style: blackThinStyle(size: 16)),
                                    AutoSizeText(
                                        'ESTABLISHED DATE: ${DateFormat('dd MMM yyyy').format(dateEstablished)}',
                                        style: blackThinStyle(size: 16)),
                                    AutoSizeText(
                                        'DATE APPROVED: ${DateFormat('dd MMM yyyy').format(dateApproved)}',
                                        style: blackThinStyle(size: 16)),
                                  ],
                                ))),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 0.5),
                                    borderRadius: BorderRadius.circular(10)),
                                child: allPadding8Pix(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                        'HEAD OF ORGANIZATION: ${orgHeadDetails['firstName']} ${orgHeadDetails['lastName']}',
                                        style: blackThinStyle(size: 16)),
                                    AutoSizeText(
                                        'CONTACT: ${orgHeadDetails['contactNumber']}',
                                        style: blackThinStyle(size: 16)),
                                    AutoSizeText(
                                        'EMAIL ADDRESS: ${orgHeadDetails['email']}',
                                        style: blackThinStyle(size: 16)),
                                    AutoSizeText(
                                        'ADVISER OF ORGANIZATION: ${orgHeadDetails['adviserFirstName']} ${orgHeadDetails['adviserLastName']}',
                                        style: blackThinStyle(size: 16)),
                                    AutoSizeText(
                                        'ADVISER CONTACT: ${orgHeadDetails['adviserContactNumber']}',
                                        style: blackThinStyle(size: 16)),
                                    AutoSizeText(
                                        'ADVISER EMAIL ADDRESS: ${orgHeadDetails['adviserEmail']}',
                                        style: blackThinStyle(size: 16)),
                                  ],
                                ))),
                          ],
                        ))
                      ],
                    ),
                  )),
            ));
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
