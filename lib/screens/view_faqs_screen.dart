import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ywda_dashboard/utils/delete_entry_dialog_util.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_button_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_miscellaneous_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/firebase_util.dart';
import '../widgets/custom_text_widgets.dart';

class ViewFAQSscreen extends StatefulWidget {
  const ViewFAQSscreen({super.key});

  @override
  State<ViewFAQSscreen> createState() => _ViewFAQsScreenState();
}

class _ViewFAQsScreenState extends State<ViewFAQSscreen> {
  bool _isLoading = true;
  bool _isInitialized = false;
  List<DocumentSnapshot> allFAQs = [];

  int pageNumber = 1;
  int maxPageNumber = 1;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasLoggedInUser()) {
        GoRouter.of(context).go('/login');
        return;
      }
      if (!_isInitialized) getAllFAQs();
    });
  }

  void getAllFAQs() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final announcements =
          await FirebaseFirestore.instance.collection('faqs').get();
      allFAQs = announcements.docs;
      maxPageNumber = (allFAQs.length / 10).ceil();
      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all FAQs: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void deleteThisFAQ(DocumentSnapshot faq) async {
    final scafffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseFirestore.instance.collection('faqs').doc(faq.id).delete();
      scafffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully deleted FAQ!')));
      getAllFAQs();
    } catch (error) {
      scafffoldMessenger
          .showSnackBar(SnackBar(content: Text('Error deleting FAQ: $error')));
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
          leftNavigator(context, 8),
          bodyWidgetWhiteBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  SingleChildScrollView(
                    child: horizontalPadding5Percent(
                        context,
                        Column(
                          children: [
                            _newFAQHeaderWidget(),
                            _FAQContainerWidget()
                          ],
                        )),
                  )))
        ]));
  }

  Widget _newFAQHeaderWidget() {
    return viewHeaderAddButton(
        addFunction: () => GoRouter.of(context).go('/faqs/add'),
        addLabel: 'ADD FAQ');
  }

  Widget _FAQContainerWidget() {
    return Column(
      children: [
        viewContentContainer(
          context,
          child: Column(
            children: [
              _FAQLabelRow(),
              allFAQs.isNotEmpty
                  ? _FAQEntries()
                  : viewContentUnavailable(context, text: 'NO FAQS AVAILABLE')
            ],
          ),
        ),
        if (allFAQs.length > 10) _navigatorButtons()
      ],
    );
  }

  Widget _FAQLabelRow() {
    return viewContentLabelRow(
      context,
      children: [
        viewFlexTextCell('Question',
            flex: 3,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Answer',
            flex: 5,
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

  Widget _FAQEntries() {
    return SizedBox(
      height: 500,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: pageNumber == maxPageNumber ? allFAQs.length % 10 : 10,
          itemBuilder: (context, index) {
            Color entryColor = index % 2 == 0 ? Colors.black : Colors.white;
            Color backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey;
            Color borderColor = index % 2 == 0 ? Colors.grey : Colors.white;
            final announcementData = allFAQs[index + ((pageNumber - 1) * 10)]
                .data() as Map<dynamic, dynamic>;
            return viewContentEntryRow(context,
                borderColor: borderColor,
                isLastEntry: index == allFAQs.length - 1,
                children: [
                  viewFlexTextCell(announcementData['question'],
                      flex: 3,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(announcementData['answer'],
                      flex: 5,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexActionsCell([
                    editEntryButton(context,
                        onPress: () => GoRouter.of(context)
                                .goNamed('editFAQ', pathParameters: {
                              'faqID':
                                  allFAQs[index + ((pageNumber - 1) * 10)].id
                            })),
                    deleteEntryButton(context, onPress: () {
                      displayDeleteEntryDialog(context,
                          message: 'Are you sure you want to delete this FAQ?',
                          deleteWord: 'Delete',
                          deleteEntry: () => deleteThisFAQ(
                              allFAQs[index + ((pageNumber - 1) * 10)]));
                    })
                  ],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor)
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
}
