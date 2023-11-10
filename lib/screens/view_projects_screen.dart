import 'package:cloud_firestore/cloud_firestore.dart';
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

class ViewProjectsScreen extends StatefulWidget {
  const ViewProjectsScreen({super.key});

  @override
  State<ViewProjectsScreen> createState() => _ViewProjectsScreenState();
}

class _ViewProjectsScreenState extends State<ViewProjectsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> allProjects = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllProjects();
  }

  void getAllProjects() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final announcements =
          await FirebaseFirestore.instance.collection('projects').get();
      allProjects = announcements.docs;
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
    return viewHeaderAddButton(
        addFunction: () => GoRouter.of(context).go('/project/addProject'),
        addLabel: 'NEW PROJECT');
  }

  Widget _projectsContainerWidget() {
    return viewContentContainer(context,
        child: Column(
          children: [
            _projectLabelRow(),
            allProjects.isNotEmpty
                ? _projectEntries()
                : viewContentUnavailable(context, text: 'NO PROJECTS AVAILABLE')
          ],
        ));
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
        viewFlexTextCell('Content',
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
    return ListView.builder(
        shrinkWrap: true,
        itemCount: allProjects.length,
        itemBuilder: (context, index) {
          Color entryColor = index % 2 == 0 ? Colors.black : Colors.white;
          Color backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey;
          Color borderColor = index % 2 == 0 ? Colors.grey : Colors.white;
          final announcementData =
              allProjects[index].data() as Map<dynamic, dynamic>;
          return viewContentEntryRow(context,
              children: [
                viewFlexTextCell('${index + 1}',
                    flex: 1,
                    backgroundColor: backgroundColor,
                    borderColor: borderColor,
                    textColor: entryColor),
                viewFlexTextCell(announcementData['title'],
                    flex: 2,
                    backgroundColor: backgroundColor,
                    borderColor: borderColor,
                    textColor: entryColor),
                viewFlexTextCell(announcementData['content'],
                    flex: 5,
                    backgroundColor: backgroundColor,
                    borderColor: borderColor,
                    textColor: entryColor),
                viewFlexTextCell(
                    DateFormat('dd MMM yyyy').format(
                        (announcementData['projectDate'] as Timestamp)
                            .toDate()),
                    flex: 2,
                    backgroundColor: backgroundColor,
                    borderColor: borderColor,
                    textColor: entryColor),
                viewFlexActionsCell([
                  editEntryButton(context,
                      onPress: () => GoRouter.of(context).goNamed('editProject',
                              pathParameters: {
                                'projectID': allProjects[index].id
                              })),
                  deleteEntryButton(context, onPress: () {
                    displayDeleteEntryDialog(context,
                        message:
                            'Are you sure you want to delete this project?',
                        deleteWord: 'Delete',
                        deleteEntry: () =>
                            deleteThisProject(allProjects[index]));
                  })
                ],
                    flex: 2,
                    backgroundColor: backgroundColor,
                    borderColor: borderColor)
              ],
              borderColor: borderColor,
              isLastEntry: index == allProjects.length - 1);
        });
  }
}
