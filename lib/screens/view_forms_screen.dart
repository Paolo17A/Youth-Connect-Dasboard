// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_widgets.dart';
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
    Map<dynamic, dynamic> fileData = file.data() as Map<dynamic, dynamic>;
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
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        ElevatedButton(
            onPressed: () {
              GoRouter.of(context).go('/forms/addForm');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 88, 147, 201),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: AutoSizeText('NEW FORM',
                  style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold))),
            ))
      ]),
    );
  }

  Widget _formsContainerWidget() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(children: [
        _announcementLabelRow(),
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: allForms.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: allForms.length,
                    itemBuilder: (context, index) {
                      double rowHeight = 50;
                      Map<dynamic, dynamic> formData =
                          allForms[index].data() as Map<dynamic, dynamic>;
                      Color entryTextColor =
                          index % 2 == 0 ? Colors.black : Colors.white;

                      Color entryBackgroundColor =
                          index % 2 == 0 ? Colors.white : Colors.grey;
                      Color entryBorderColor =
                          index % 2 != 0 ? Colors.white : Colors.grey;

                      return Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          color: entryBackgroundColor,
                        ),
                        child: Row(
                          children: [
                            Flexible(
                                flex: 1,
                                child: Container(
                                  height: rowHeight,
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: entryBorderColor)),
                                  child: Center(
                                      child: AutoSizeText('${index + 1}',
                                          style: _formsEntryStyle(
                                              entryTextColor))),
                                )),
                            Flexible(
                              flex: 3,
                              child: Container(
                                height: rowHeight,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: entryBorderColor)),
                                child: Center(
                                    child: AutoSizeText(formData['fileName'],
                                        style:
                                            _formsEntryStyle(entryTextColor))),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                height: rowHeight,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: entryBorderColor)),
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          downloadFile(formData['fileURL']);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green),
                                        child: const Icon(Icons.download)),
                                    ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  content: const Text(
                                                      'Are you sure you want to delete this form?'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        GoRouter.of(context)
                                                            .pop();
                                                      },
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        GoRouter.of(context)
                                                            .pop();
                                                        deleteFile(
                                                            allForms[index]);
                                                      },
                                                      child:
                                                          const Text('Delete'),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        child: const Icon(Icons.delete,
                                            color: Colors.white))
                                  ],
                                )),
                              ),
                            )
                          ],
                        ),
                      );
                    })
                : _noFormsAvailableWidget())
      ]),
    );
  }

  Widget _announcementLabelRow() {
    double rowHeight = 50;
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: Colors.grey,
      ),
      child: Row(
        children: [
          Flexible(
              flex: 1,
              child: Container(
                height: rowHeight,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.white)),
                child: Center(
                    child: AutoSizeText('#',
                        style: _formsEntryStyle(Colors.white))),
              )),
          Flexible(
            flex: 3,
            child: Container(
              height: rowHeight,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Center(
                  child: AutoSizeText('File Name',
                      style: _formsEntryStyle(Colors.white))),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              height: rowHeight,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Center(
                  child: AutoSizeText('Actions',
                      style: _formsEntryStyle(Colors.white))),
            ),
          )
        ],
      ),
    );
  }

  Widget _noFormsAvailableWidget() {
    return Center(
      child: Text(
        'NO FORMS AVAILABLE',
        style: GoogleFonts.poppins(
            textStyle: const TextStyle(
                fontSize: 38,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  TextStyle _formsEntryStyle(Color thisColor) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
            color: thisColor, fontSize: 23, fontWeight: FontWeight.w400));
  }
}
