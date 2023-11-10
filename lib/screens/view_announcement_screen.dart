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

class ViewAnnouncementScreen extends StatefulWidget {
  const ViewAnnouncementScreen({super.key});

  @override
  State<ViewAnnouncementScreen> createState() => _ViewAnnouncementScreenState();
}

class _ViewAnnouncementScreenState extends State<ViewAnnouncementScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> allAnnouncements = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllAnnouncements();
  }

  void getAllAnnouncements() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final announcements =
          await FirebaseFirestore.instance.collection('announcements').get();
      allAnnouncements = announcements.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all announcements: $error')));
    }
  }

  void deleteThisAnnouncement(DocumentSnapshot announcement) async {
    final scafffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      List<dynamic> images =
          (announcement.data() as Map<dynamic, dynamic>)['imageURLs'];

      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(announcement.id)
          .delete();

      if (images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('posts')
              .child('announcements')
              .child(announcement.id);

          await storageRef.delete();
        }
      }
      getAllAnnouncements();

      scafffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully deleted announcement!')));
    } catch (error) {
      scafffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error deleting announcement: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
        body: Row(children: [
          leftNavigator(context, 6),
          bodyWidgetWhiteBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  horizontalPadding5Percent(
                      context,
                      Column(
                        children: [
                          _newAnnouncementHeaderWidget(),
                          _announcementContainerWidget()
                        ],
                      ))))
        ]));
  }

  Widget _newAnnouncementHeaderWidget() {
    return viewHeaderAddButton(
        addFunction: () {
          GoRouter.of(context).go('/announcement/addAnnouncement');
        },
        addLabel: 'ADD ANNOUNCEMENT');
  }

  Widget _announcementContainerWidget() {
    return viewContentContainer(
      context,
      child: Column(
        children: [
          _announcementLabelRow(),
          allAnnouncements.isNotEmpty
              ? _announcementEntries()
              : viewContentUnavailable(context,
                  text: 'NO ANNOUNCEMENTS AVAILABLE')
        ],
      ),
    );
  }

  Widget _announcementLabelRow() {
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
        viewFlexTextCell('Date Created',
            flex: 2,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Actions',
            flex: 2,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
      ],
    );
  }

  Widget _announcementEntries() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: allAnnouncements.length,
        itemBuilder: (context, index) {
          Color entryColor = index % 2 == 0 ? Colors.black : Colors.white;
          Color backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey;
          Color borderColor = index % 2 == 0 ? Colors.grey : Colors.white;
          final announcementData =
              allAnnouncements[index].data() as Map<dynamic, dynamic>;
          String convertedDateAdded = DateFormat('dd MMM yyyy')
              .format((announcementData['dateAdded'] as Timestamp).toDate());
          return viewContentEntryRow(context,
              borderColor: borderColor,
              isLastEntry: index == allAnnouncements.length - 1,
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
                viewFlexTextCell(convertedDateAdded,
                    flex: 2,
                    backgroundColor: backgroundColor,
                    borderColor: borderColor,
                    textColor: entryColor),
                viewFlexActionsCell([
                  editEntryButton(context, onPress: () {
                    GoRouter.of(context).goNamed('editAnnouncement',
                        pathParameters: {
                          'announcementID': allAnnouncements[index].id
                        });
                  }),
                  deleteEntryButton(context, onPress: () {
                    displayDeleteEntryDialog(context,
                        message:
                            'Are you sure you want to delete this announcement?',
                        deleteWord: 'Delete',
                        deleteEntry: () =>
                            deleteThisAnnouncement(allAnnouncements[index]));
                  })
                ],
                    flex: 2,
                    backgroundColor: backgroundColor,
                    borderColor: borderColor)
              ]);
        });
  }
}
