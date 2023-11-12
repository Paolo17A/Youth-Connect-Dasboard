import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          print(
              '$organizer: ${organizer != FirebaseAuth.instance.currentUser!.uid}');
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
      filteredProjects = List.from(allProjects);
      maxPageNumber = (filteredProjects.length / 10).ceil();

      associatedHeads.clear();
      for (var project in allProjects) {
        final projectData = project.data() as Map<dynamic, dynamic>;
        final headID = projectData['organizer'];
        if (headID == FirebaseAuth.instance.currentUser!.uid) {
          associatedHeads[headID] = 'ADMIN PROJECT';
        } else {
          if (associatedHeads.containsKey(headID)) {
            continue;
          }
          final user = await FirebaseFirestore.instance
              .collection('users')
              .doc(headID)
              .get();

          final userData = user.data() as Map<dynamic, dynamic>;
          print('userData: $userData');
          associatedHeads[headID] = userData['organization'];
        }
      }
      print(associatedHeads);

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
            flex: 5,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Project Date',
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
      height: MediaQuery.of(context).size.height * 0.52,
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
                      flex: 5,
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
                  viewFlexActionsCell([
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
