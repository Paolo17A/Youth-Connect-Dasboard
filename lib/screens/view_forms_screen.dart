// ignore_for_file: avoid_web_libraries_in_flutter

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

class ViewFormsScreen extends StatefulWidget {
  const ViewFormsScreen({super.key});

  @override
  State<ViewFormsScreen> createState() => _ViewFormsScreenState();
}

class _ViewFormsScreenState extends State<ViewFormsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> allForms = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllForms();
  }

  Future getAllForms() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final forms = await FirebaseFirestore.instance.collection('forms').get();
      allForms = forms.docs;
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
          bodyWidgetWhiteBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  horizontalPadding5Percent(
                      context,
                      Column(
                        children: [
                          _newFormHeaderWidget(),
                          _formsContainerWidget()
                        ],
                      ))))
        ]));
  }

  Widget _newFormHeaderWidget() {
    return viewHeaderAddButton(
        addFunction: () => GoRouter.of(context).go('/forms/addForm'),
        addLabel: 'NEW FORM');
  }

  Widget _formsContainerWidget() {
    return viewContentContainer(context,
        child: Column(children: [
          _announcementLabelRow(),
          allForms.isNotEmpty
              ? _formEntries()
              : viewContentUnavailable(context, text: 'NO FORMS AVAILABLE')
        ]));
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
        viewFlexTextCell('File Name',
            flex: 3,
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

  Widget _formEntries() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: allForms.length,
        itemBuilder: (context, index) {
          final formData = allForms[index].data() as Map<dynamic, dynamic>;
          Color entryColor = index % 2 == 0 ? Colors.black : Colors.white;
          Color backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey;
          Color borderColor = index % 2 == 0 ? Colors.grey : Colors.white;
          return viewContentEntryRow(context,
              children: [
                viewFlexTextCell('${index + 1}',
                    flex: 1,
                    backgroundColor: backgroundColor,
                    borderColor: borderColor,
                    textColor: entryColor),
                viewFlexTextCell(formData['fileName'],
                    flex: 3,
                    backgroundColor: backgroundColor,
                    borderColor: borderColor,
                    textColor: entryColor),
                viewFlexActionsCell([
                  downloadFileButton(context, onPress: () {
                    downloadFile(formData['fileURL']);
                  }),
                  deleteEntryButton(context, onPress: () {
                    displayDeleteEntryDialog(context,
                        message: 'Are you sure you want to delete this form?',
                        deleteWord: 'Delete',
                        deleteEntry: () => deleteFile(allForms[index]));
                  })
                ],
                    flex: 2,
                    backgroundColor: backgroundColor,
                    borderColor: borderColor)
              ],
              borderColor: borderColor,
              isLastEntry: index == allForms.length - 1);
        });
  }
}
