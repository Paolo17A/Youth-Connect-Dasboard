// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ywda_dashboard/utils/delete_entry_dialog_util.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_button_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_miscellaneous_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';
import 'dart:html' as html;

import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';

class ViewFormsScreen extends StatefulWidget {
  const ViewFormsScreen({super.key});

  @override
  State<ViewFormsScreen> createState() => _ViewFormsScreenState();
}

class _ViewFormsScreenState extends State<ViewFormsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> allForms = [];

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
      getAllForms();
    });
  }

  Future getAllForms() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final forms = await FirebaseFirestore.instance.collection('forms').get();
      allForms = forms.docs;
      maxPageNumber = (allForms.length / 10).ceil();
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all forms: $error')));
    }
  }

  void downloadFile(String url) {
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
  }

  Future deleteFile(DocumentSnapshot file) async {
    final scafffoldMessenger = ScaffoldMessenger.of(context);
    final fileData = file.data() as Map<dynamic, dynamic>;
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('forms')
          .doc(file.id)
          .delete();

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('forms')
          .child(file.id)
          .child(fileData['fileName']);

      await storageRef.delete();
      getAllForms();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
        body: Row(children: [
          leftNavigator(context, 3),
          bodyWidgetMercuryBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  SingleChildScrollView(
                    child: horizontalPadding5Percent(
                        context,
                        Column(
                          children: [
                            _newFormHeaderWidget(),
                            _formsContainerWidget()
                          ],
                        )),
                  )))
        ]));
  }

  Widget _newFormHeaderWidget() {
    return viewHeaderAddButton(
        addFunction: () => GoRouter.of(context).go('/forms/addForm'),
        addLabel: 'NEW FORM');
  }

  Widget _formsContainerWidget() {
    return Column(
      children: [
        viewContentContainer(context,
            child: Column(children: [
              _announcementLabelRow(),
              allForms.isNotEmpty
                  ? _formEntries()
                  : viewContentUnavailable(context, text: 'NO FORMS AVAILABLE')
            ])),
        if (allForms.length > 10) _navigatorButtons()
      ],
    );
  }

  Widget _announcementLabelRow() {
    return viewContentLabelRow(
      context,
      children: [
        viewFlexTextCell('#',
            flex: 1, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('File Name',
            flex: 3, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('Actions',
            flex: 2, backgroundColor: Colors.grey.withOpacity(0.5))
      ],
    );
  }

  Widget _formEntries() {
    return SizedBox(
      height: 500,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: pageNumber == maxPageNumber ? allForms.length % 10 : 10,
          itemBuilder: (context, index) {
            final formData = allForms[index + ((pageNumber - 1) * 10)].data()
                as Map<dynamic, dynamic>;
            Color backgroundColor =
                index % 2 == 0 ? Colors.white : Colors.grey.withOpacity(0.5);
            Color borderColor =
                index % 2 == 0 ? Colors.grey.withOpacity(0.5) : Colors.white;
            return viewContentEntryRow(context,
                children: [
                  viewFlexTextCell('${(index + 1) + ((pageNumber - 1) * 10)}',
                      flex: 1, backgroundColor: backgroundColor),
                  viewFlexTextCell(formData['fileName'],
                      flex: 3, backgroundColor: backgroundColor),
                  viewFlexActionsCell([
                    downloadFileButton(context, onPress: () {
                      downloadFile(formData['fileURL']);
                    }),
                    deleteEntryButton(context, onPress: () {
                      displayDeleteEntryDialog(context,
                          message: 'Are you sure you want to delete this form?',
                          deleteWord: 'Delete',
                          deleteEntry: () => deleteFile(
                              allForms[index + ((pageNumber - 1) * 10)]));
                    })
                  ], flex: 2, backgroundColor: backgroundColor)
                ],
                borderColor: borderColor,
                isLastEntry: index == allForms.length - 1);
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
      ),
    );
  }
}
