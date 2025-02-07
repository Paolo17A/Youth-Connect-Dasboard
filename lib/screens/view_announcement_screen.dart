import 'package:auto_size_text/auto_size_text.dart';
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

import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';

class ViewAnnouncementScreen extends StatefulWidget {
  const ViewAnnouncementScreen({super.key});

  @override
  State<ViewAnnouncementScreen> createState() => _ViewAnnouncementScreenState();
}

class _ViewAnnouncementScreenState extends State<ViewAnnouncementScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> allAnnouncements = [];
  int pageNumber = 1;
  int maxPageNumber = 1;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasLoggedInUser()) {
        GoRouter.of(context).goNamed(GoRoutes.login);
        return;
      }
      getAllAnnouncements();
    });
  }

  void getAllAnnouncements() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final announcements =
          await FirebaseFirestore.instance.collection('announcements').get();
      allAnnouncements = announcements.docs;
      allAnnouncements.reversed.toList();
      maxPageNumber = (allAnnouncements.length / 10).ceil();
      if (!mounted) {
        return;
      }
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
          bodyWidgetMercuryBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  SingleChildScrollView(
                    child: horizontalPadding5Percent(
                        context,
                        Column(
                          children: [
                            _newAnnouncementHeaderWidget(),
                            _announcementContainerWidget()
                          ],
                        )),
                  )))
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
    return Column(
      children: [
        viewContentContainer(
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
        ),
        if (allAnnouncements.length > 10) _navigatorButtons()
      ],
    );
  }

  Widget _announcementLabelRow() {
    return viewContentLabelRow(
      context,
      children: [
        viewFlexTextCell('#',
            flex: 1, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('Title',
            flex: 2, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('Content',
            flex: 5, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('Date Created',
            flex: 2, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('Actions',
            flex: 2, backgroundColor: Colors.grey.withOpacity(0.5)),
      ],
    );
  }

  Widget _announcementEntries() {
    return SizedBox(
      height: 500,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount:
              pageNumber == maxPageNumber && allAnnouncements.length != 10
                  ? allAnnouncements.length % 10
                  : 10,
          itemBuilder: (context, index) {
            Color backgroundColor =
                index % 2 == 0 ? Colors.white : Colors.grey.withOpacity(0.5);
            Color borderColor =
                index % 2 == 0 ? Colors.grey.withOpacity(0.5) : Colors.white;
            final announcementData =
                allAnnouncements[index + ((pageNumber - 1) * 10)].data()
                    as Map<dynamic, dynamic>;
            String convertedDateAdded = DateFormat('dd MMM yyyy')
                .format((announcementData['dateAdded'] as Timestamp).toDate());
            return viewContentEntryRow(context,
                borderColor: borderColor,
                isLastEntry: index == allAnnouncements.length - 1,
                children: [
                  viewFlexTextCell('${(index + 1) + ((pageNumber - 1) * 10)}',
                      flex: 1, backgroundColor: backgroundColor),
                  viewFlexTextCell(announcementData['title'],
                      flex: 2, backgroundColor: backgroundColor),
                  viewFlexTextCell(announcementData['content'],
                      flex: 5, backgroundColor: backgroundColor),
                  viewFlexTextCell(convertedDateAdded,
                      flex: 2, backgroundColor: backgroundColor),
                  viewFlexActionsCell([
                    editEntryButton(context, onPress: () {
                      GoRouter.of(context)
                          .goNamed('editAnnouncement', pathParameters: {
                        'announcementID':
                            allAnnouncements[index + ((pageNumber - 1) * 10)].id
                      });
                    }),
                    deleteEntryButton(context, onPress: () {
                      displayDeleteEntryDialog(context,
                          message:
                              'Are you sure you want to delete this announcement?',
                          deleteWord: 'Delete',
                          deleteEntry: () => deleteThisAnnouncement(
                              allAnnouncements[
                                  index + ((pageNumber - 1) * 10)]));
                    })
                  ], flex: 2, backgroundColor: backgroundColor)
                ]);
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
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: CustomColors.darkBlue)),
                child: Padding(
                  padding: const EdgeInsets.all(5.5),
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
          )),
    );
  }
}
