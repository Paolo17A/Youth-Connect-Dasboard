import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ywda_dashboard/utils/delete_entry_dialog_util.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_button_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_miscellaneous_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../widgets/custom_text_widgets.dart';
import '../widgets/dropdown_widget.dart';

class ViewProjectsScreen extends StatefulWidget {
  const ViewProjectsScreen({super.key});

  @override
  State<ViewProjectsScreen> createState() => _ViewProjectsScreenState();
}

class _ViewProjectsScreenState extends State<ViewProjectsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> allProjects = [];
  List<DocumentSnapshot> filteredProjects = [];
  String _selectedCategory = '';
  Map<String, String> associatedHeads = {}; //  userID - orgID
  Map<String, String> associatedOrgs = {}; //  orgID - orgName
  Map<String, String> associatedParticipants = {}; //   userID - user name

  int pageNumber = 1;
  int maxPageNumber = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllProjects();
  }

  void _onSelectFilter() {
    setState(() {
      if (_selectedCategory == 'ALL') {
        filteredProjects = allProjects;
      } else if (_selectedCategory == 'ADMIN PROJECTS') {
        filteredProjects = allProjects.where((project) {
          final projectData = project.data()! as Map<dynamic, dynamic>;
          String organizer = projectData['organizer'].toString();
          return organizer == FirebaseAuth.instance.currentUser!.uid;
        }).toList();
      } else if (_selectedCategory == 'ORG PROJECTS') {
        filteredProjects = allProjects.where((project) {
          final projectData = project.data()! as Map<dynamic, dynamic>;
          String organizer = projectData['organizer'];
          return organizer != FirebaseAuth.instance.currentUser!.uid;
        }).toList();
      }
      maxPageNumber = (filteredProjects.length / 10).ceil();
    });
  }

  void getAllProjects() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final announcements =
          await FirebaseFirestore.instance.collection('projects').get();
      allProjects = announcements.docs;
      allProjects = allProjects.reversed.toList();
      filteredProjects = List.from(allProjects);
      maxPageNumber = (filteredProjects.length / 10).ceil();

      associatedHeads.clear();
      associatedParticipants.clear();
      for (var project in allProjects) {
        final projectData = project.data() as Map<dynamic, dynamic>;
        final headID = projectData['organizer'];

        //  get all associated heads
        if (headID == FirebaseAuth.instance.currentUser!.uid) {
          associatedHeads[headID] = 'YDA PROJECT';
        } else {
          if (associatedHeads.containsKey(headID)) {
            continue;
          }
          final user = await FirebaseFirestore.instance
              .collection('users')
              .doc(headID)
              .get();

          final userData = user.data() as Map<dynamic, dynamic>;
          associatedHeads[headID] = userData['organization'];
        }

        //  get all associated participants
        final participants = projectData['participants'] as List<dynamic>;
        for (var participant in participants) {
          if (associatedParticipants.containsKey(participant)) {
            continue;
          }
          final getParticipant = await FirebaseFirestore.instance
              .collection('users')
              .doc(participant)
              .get();
          final participantData =
              getParticipant.data() as Map<dynamic, dynamic>;
          String formattedName =
              '${participantData['firstName']} ${participantData['lastName']}';
          associatedParticipants[participant] = formattedName;
        }
      }

      associatedOrgs.clear();
      for (var head in associatedHeads.entries) {
        final orgID = head.value;
        if (orgID == 'ADMIN PROJECT') {
          associatedOrgs[orgID] = 'ADMIN PROJECT';
        } else {
          if (associatedHeads.containsKey(orgID)) {
            continue;
          }
          final org = await FirebaseFirestore.instance
              .collection('orgs')
              .doc(orgID)
              .get();
          final orgData = org.data() as Map<dynamic, dynamic>;
          final orgName = orgData['name'];
          associatedOrgs[orgID] = orgName;
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all projects: $error')));
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
        appBar: appBarWidget(context),
        body: Row(children: [
          leftNavigator(context, 5),
          bodyWidgetWhiteBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  horizontalPadding5Percent(
                      context,
                      Column(
                        children: [
                          _newProjectHeaderWidget(),
                          _projectsContainerWidget(),
                        ],
                      ))))
        ]));
  }

  //  COMPONENT WIDGETS
  //============================================================================
  Widget _newProjectHeaderWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: dropdownWidget(_selectedCategory, (selected) {
            setState(() {
              _selectedCategory = selected!;
              _onSelectFilter();
            });
          }, ['ALL', 'ADMIN PROJECTS', 'ORG PROJECTS'], _selectedCategory,
              false),
        ),
        viewHeaderAddButton(
            addFunction: () => GoRouter.of(context).go('/project/addProject'),
            addLabel: 'NEW PROJECT'),
      ],
    );
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
        if (filteredProjects.length > 10) _navigatorButtons()
      ],
    );
  }

  Widget _projectLabelRow() {
    return viewContentLabelRow(
      context,
      children: [
        viewFlexTextCell('#',
            flex: 1,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Title',
            flex: 2,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Organizer',
            flex: 3,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Date Created',
            flex: 2,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Start Date',
            flex: 2,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('End Date',
            flex: 2,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Actions',
            flex: 2,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white)
      ],
    );
  }

  Widget _projectEntries() {
    return SizedBox(
      height: 500,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount:
              pageNumber == maxPageNumber ? filteredProjects.length % 10 : 10,
          itemBuilder: (context, index) {
            Color entryColor = index % 2 == 0 ? Colors.black : Colors.white;
            Color backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey;
            Color borderColor = index % 2 == 0 ? Colors.grey : Colors.white;
            final projectData =
                filteredProjects[index + ((pageNumber - 1) * 10)].data()
                    as Map<dynamic, dynamic>;
            final participants = projectData['participants'] as List<dynamic>;
            final names = [];
            for (var element in associatedParticipants.entries) {
              if (participants.contains(element.key)) {
                names.add(element.value);
              }
            }
            return viewContentEntryRow(context,
                children: [
                  viewFlexTextCell('#${(index + 1) + ((pageNumber - 1) * 10)}',
                      flex: 1,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(projectData['title'],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(
                      associatedOrgs[
                          associatedHeads[projectData['organizer']]]!,
                      flex: 3,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(
                      DateFormat('dd MMM yyyy').format(
                          (projectData['dateAdded'] as Timestamp).toDate()),
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(
                      DateFormat('dd MMM yyyy').format(
                          (projectData['projectDate'] as Timestamp).toDate()),
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  if (projectData.containsKey('projectDateEnd'))
                    viewFlexTextCell(
                        DateFormat('dd MMM yyyy').format(
                            (projectData['projectDateEnd'] as Timestamp)
                                .toDate()),
                        flex: 2,
                        backgroundColor: backgroundColor,
                        borderColor: borderColor,
                        textColor: entryColor),
                  viewFlexActionsCell([
                    viewEntryPopUpButton(context,
                        onPress: () => showParticipantsDialog(names)),
                    editEntryButton(context,
                        onPress: () => GoRouter.of(context)
                                .goNamed('editProject', pathParameters: {
                              'projectID': filteredProjects[
                                      index + ((pageNumber - 1) * 10)]
                                  .id
                            })),
                    deleteEntryButton(context, onPress: () {
                      displayDeleteEntryDialog(context,
                          message:
                              'Are you sure you want to delete this project?',
                          deleteWord: 'Delete',
                          deleteEntry: () => deleteThisProject(filteredProjects[
                              index + ((pageNumber - 1) * 10)]));
                    })
                  ],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor)
                ],
                borderColor: borderColor,
                isLastEntry: index == filteredProjects.length - 1);
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

  void showParticipantsDialog(List<dynamic> projectParticipants) {
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
                                  children: projectParticipants
                                      .map((person) => AutoSizeText(person,
                                          style: GoogleFonts.poppins(
                                              fontSize: 30)))
                                      .toList()),
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
