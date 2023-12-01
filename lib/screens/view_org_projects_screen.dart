import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ywda_dashboard/utils/delete_entry_dialog_util.dart';
import 'package:ywda_dashboard/utils/go_router_util.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_button_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_miscellaneous_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/color_util.dart';
import '../utils/firebase_util.dart';

class ViewOrgProjectsScreen extends StatefulWidget {
  const ViewOrgProjectsScreen({super.key});

  @override
  State<ViewOrgProjectsScreen> createState() => _ViewOrgProjectsScreenState();
}

class _ViewOrgProjectsScreenState extends State<ViewOrgProjectsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> allProjects = [];
  List<DocumentSnapshot> participantDocs = [];
  List<DocumentSnapshot> orgDocs = [];
  //Map<String, String> associatedParticipants = {}; //   userID - user name

  int pageNumber = 1;
  int maxPageNumber = 1;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasLoggedInUser()) {
        GoRouter.of(context).goNamed(GoRoutes.login);
        return;
      }
      getAllProjects();
    });
  }

  void getAllProjects() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final projects = await FirebaseFirestore.instance
          .collection('projects')
          .where('organizer', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      allProjects = projects.docs;
      allProjects = allProjects.reversed.toList();
      maxPageNumber = (allProjects.length / 10).ceil();

      //  get all associated participants
      List<dynamic> participantIDs = [];
      for (var project in allProjects) {
        final projectData = project.data() as Map<dynamic, dynamic>;
        final participants = projectData['participants'] as List<dynamic>;
        for (var participant in participants) {
          if (!participantIDs.contains(participant)) {
            participantIDs.add(participant);
          }
        }
        if (participantIDs.isNotEmpty) {
          final allParticipants = await FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: participantIDs)
              .get();
          participantDocs = allParticipants.docs;
        }
      }

      List<dynamic> orgIDs = [];
      for (var particant in participantDocs) {
        final participantData = particant.data() as Map<dynamic, dynamic>;
        final orgID = participantData['organization'];
        if (!orgIDs.contains(orgID)) {
          orgIDs.add(orgID);
        }
      }

      if (orgIDs.isNotEmpty) {
        final orgs = await FirebaseFirestore.instance
            .collection('orgs')
            .where(FieldPath.documentId, whereIn: orgIDs)
            .get();
        orgDocs = orgs.docs;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting your projects: $error')));
    }
  }

  void deleteThisProject(DocumentSnapshot project) async {
    final scafffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      List<dynamic> images =
          (project.data() as Map<dynamic, dynamic>)['imageURLs'];

      await FirebaseFirestore.instance
          .collection('projects')
          .doc(project.id)
          .delete();

      if (images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('posts')
              .child('projects')
              .child(project.id);

          await storageRef.delete();
        }
      }
      getAllProjects();

      scafffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully deleted project!')));
    } catch (error) {
      scafffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error deleting project: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  //  BUILD WIDGET
  //============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: orgAppBarWidget(context),
        body: Row(children: [
          orgLeftNavigator(context, GoRoutes.orgProjects),
          bodyWidgetWhiteBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  SingleChildScrollView(
                    child: horizontalPadding5Percent(
                        context,
                        Column(
                          children: [
                            _newProjectHeaderWidget(),
                            _projectsContainerWidget()
                          ],
                        )),
                  )))
        ]));
  }

  //  COMPONENT WIDGETS
  //============================================================================
  Widget _newProjectHeaderWidget() {
    return viewHeaderAddButton(
        addFunction: () => GoRouter.of(context).go('/orgProjects/add'),
        addLabel: 'NEW PROJECT');
  }

  Widget _projectsContainerWidget() {
    return Column(
      children: [
        viewContentContainer(context,
            child: Column(
              children: [
                _projectLabelRow(),
                allProjects.isNotEmpty
                    ? _projectEntries()
                    : viewContentUnavailable(context,
                        text: 'NO PROJECTS AVAILABLE')
              ],
            )),
        if (allProjects.length > 10) _navigatorButtons()
      ],
    );
  }

  Widget _projectLabelRow() {
    return viewContentLabelRow(
      context,
      children: [
        viewFlexTextCell('#',
            flex: 1, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('Title',
            flex: 2, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('Content',
            flex: 4, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('Project Date',
            flex: 2, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('Start Date',
            flex: 2, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('End Date',
            flex: 2, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('Actions',
            flex: 2, backgroundColor: Colors.grey.withOpacity(0.5))
      ],
    );
  }

  Widget _projectEntries() {
    return SizedBox(
      height: 500,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: pageNumber == maxPageNumber ? allProjects.length % 10 : 10,
          itemBuilder: (context, index) {
            Color backgroundColor =
                index % 2 == 0 ? Colors.white : Colors.grey.withOpacity(0.5);
            Color borderColor =
                index % 2 == 0 ? Colors.grey.withOpacity(0.5) : Colors.white;
            final projectData = allProjects[index + ((pageNumber - 1) * 10)]
                .data() as Map<dynamic, dynamic>;
            final participants = projectData['participants'] as List<dynamic>;
            List<DocumentSnapshot> filteredParticipants = participantDocs
                .where((participant) => participants.contains(participant.id))
                .toList();
            return viewContentEntryRow(context,
                children: [
                  viewFlexTextCell('${(index + 1) + ((pageNumber - 1) * 10)}',
                      flex: 1, backgroundColor: backgroundColor),
                  viewFlexTextCell(projectData['title'],
                      flex: 2, backgroundColor: backgroundColor),
                  viewFlexTextCell(projectData['content'],
                      flex: 4, backgroundColor: backgroundColor),
                  viewFlexTextCell(
                      DateFormat('dd MMM yyyy').format(
                          (projectData['dateAdded'] as Timestamp).toDate()),
                      flex: 2,
                      backgroundColor: backgroundColor),
                  viewFlexTextCell(
                      DateFormat('dd MMM yyyy').format(
                          (projectData['projectDate'] as Timestamp).toDate()),
                      flex: 2,
                      backgroundColor: backgroundColor),
                  viewFlexTextCell(
                      DateFormat('dd MMM yyyy').format(
                          (projectData['projectDateEnd'] as Timestamp)
                              .toDate()),
                      flex: 2,
                      backgroundColor: backgroundColor),
                  viewFlexActionsCell([
                    viewEntryPopUpButton(context,
                        onPress: () =>
                            showParticipantsDialog(filteredParticipants)),
                    editEntryButton(context,
                        onPress: () => GoRouter.of(context)
                                .goNamed('editOrgProject', pathParameters: {
                              'projectID':
                                  allProjects[index + ((pageNumber - 1) * 10)]
                                      .id
                            })),
                    deleteEntryButton(context, onPress: () {
                      displayDeleteEntryDialog(context,
                          message:
                              'Are you sure you want to delete this project?',
                          deleteWord: 'Delete',
                          deleteEntry: () => deleteThisProject(
                              allProjects[index + ((pageNumber - 1) * 10)]));
                    })
                  ], flex: 2, backgroundColor: backgroundColor)
                ],
                borderColor: borderColor,
                isLastEntry: index == allProjects.length - 1);
          }),
    );
  }

  Widget _navigatorButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
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
          Container(
            decoration:
                BoxDecoration(border: Border.all(color: CustomColors.darkBlue)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: AutoSizeText(pageNumber.toString(),
                  style: TextStyle(color: CustomColors.darkBlue)),
            ),
          ),
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
      ),
    );
  }

  void showParticipantsDialog(List<DocumentSnapshot> projectParticipants) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(children: [
                  AutoSizeText('PROJECT PARTICIPANTS',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 50)),
                  projectParticipants.isNotEmpty
                      ? Row(
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                  children: projectParticipants.map((person) {
                                final participantData =
                                    person.data() as Map<dynamic, dynamic>;
                                String formattedName =
                                    '${participantData['firstName']} ${participantData['lastName']}';
                                String organization =
                                    participantData['organization'];
                                DocumentSnapshot orgDoc = orgDocs
                                    .where((org) => org.id == organization)
                                    .first;
                                final orgData =
                                    orgDoc.data() as Map<dynamic, dynamic>;
                                String orgName = orgData['name'];
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      decoration:
                                          BoxDecoration(border: Border.all()),
                                      child: Center(
                                        child: AutoSizeText(formattedName,
                                            style: GoogleFonts.poppins(
                                                fontSize: 30)),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      decoration:
                                          BoxDecoration(border: Border.all()),
                                      child: Center(
                                        child: AutoSizeText(orgName,
                                            style: GoogleFonts.poppins(
                                                fontSize: 30)),
                                      ),
                                    )
                                  ],
                                );
                              }).toList()),
                            ),
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.all(50),
                          child: AutoSizeText(
                              'THIS PROJECT HAS NO PARTICIPANTS',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 30)),
                        )
                ]),
              ),
            ));
  }
}
