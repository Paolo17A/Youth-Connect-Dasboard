import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ywda_dashboard/utils/delete_entry_dialog_util.dart';
import 'package:ywda_dashboard/utils/url_util.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_button_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/dropdown_widget.dart';

class ViewOrgRenewalsScreen extends StatefulWidget {
  const ViewOrgRenewalsScreen({super.key});

  @override
  State<ViewOrgRenewalsScreen> createState() => _ViewOrgRenewalsScreenState();
}

class _ViewOrgRenewalsScreenState extends State<ViewOrgRenewalsScreen> {
  bool isLoading = true;
  bool isInitialized = false;
  List<DocumentSnapshot> allAccreds = [];
  List<DocumentSnapshot> filteredAccreds = [];
  Map<String, dynamic> associatedOrgs = {};
  String _selectedCategory = '';
  Uint8List? _formCertificationSelectedFileBytes;
  String? _formCertificationSelectedFileName;
  String? _formCertificationSelectedFileExtension;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) getAllRenewalRequests();
  }

  void _onSelectFilter() {
    setState(() {
      if (_selectedCategory == 'NO FILTER') {
        filteredAccreds = allAccreds;
        print('filtered accreds count: ${filteredAccreds.length}');
      } else {
        filteredAccreds = allAccreds.where((accred) {
          final accredData = accred.data() as Map<dynamic, dynamic>;
          String accredStatus = accredData['status'];
          return accredStatus == _selectedCategory;
        }).toList();
      }
    });
  }

  Future pickFormAccreditation() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        if (result.files.first.extension != 'pdf' &&
            result.files.first.extension != 'doc' &&
            result.files.first.extension != 'docx') {
          scaffoldMessenger.showSnackBar(const SnackBar(
              content: Text('Please select a .pdf, .doc, or .docx file.')));
          return;
        }
        setState(() {
          _formCertificationSelectedFileBytes = result.files.first.bytes;
          _formCertificationSelectedFileName = result.files.first.name;
          _formCertificationSelectedFileExtension =
              result.files.first.extension;
        });
        setState(() {});
      } else {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Selected File is null.')));
      }
    } catch (error) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Error picking file: $error')));
    }
  }

  Future getAllRenewalRequests() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final accreds =
          await FirebaseFirestore.instance.collection('accreditations').get();
      allAccreds = accreds.docs;
      filteredAccreds = List.from(accreds.docs);
      associatedOrgs.clear();
      for (var accred in accreds.docs) {
        final accredData = accred.data();
        String orgID = accredData['orgID'];
        if (associatedOrgs.containsKey(orgID)) {
          continue;
        }
        final thisOrg = await FirebaseFirestore.instance
            .collection('orgs')
            .doc(orgID)
            .get();
        associatedOrgs[orgID] = thisOrg.data();
      }

      setState(() {
        isLoading = false;
        isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error getting all org renewal requests: $error')));
      setState(() {
        isLoading = false;
      });
    }
  }

  Future denyRenewalRequest() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context),
      body: Row(children: [
        leftNavigator(context, 2.1),
        bodyWidgetWhiteBG(
            context,
            switchedLoadingContainer(
                isLoading,
                SingleChildScrollView(
                  child: horizontalPadding5Percent(
                      context,
                      Column(children: [
                        _filterAccredsHeaderWidget(),
                        _accredsContainerWidget()
                      ])),
                )))
      ]),
    );
  }

  Widget _filterAccredsHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: dropdownWidget(_selectedCategory, (selected) {
            _selectedCategory = selected!;
            _onSelectFilter();
          }, ['NO FILTER', 'DISAPPROVED', 'PENDING', 'APPROVED'], '', false),
        ),
      ]),
    );
  }

  Widget _accredsContainerWidget() {
    return viewContentContainer(context,
        child: Column(
          children: [
            _accredsLabelRow(),
            filteredAccreds.isNotEmpty
                ? _accredEntries()
                : viewContentUnavailable(context,
                    text: 'NO ACCREDITATION REQUESTS AVAILABLE')
          ],
        ));
  }

  Widget _accredsLabelRow() {
    return viewContentLabelRow(
      context,
      children: [
        viewFlexTextCell('#',
            flex: 1,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Name',
            flex: 3,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Accreditation Form',
            flex: 2,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Status',
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

  Widget _accredEntries() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredAccreds.length,
          itemBuilder: (context, index) {
            final accredData =
                filteredAccreds[index].data() as Map<dynamic, dynamic>;
            final orgData =
                associatedOrgs[accredData['orgID']] as Map<dynamic, dynamic>;
            Color entryColor = index % 2 == 0 ? Colors.black : Colors.white;
            Color backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey;
            Color borderColor = index % 2 == 0 ? Colors.grey : Colors.white;

            return viewContentEntryRow(context,
                children: [
                  viewFlexTextCell('#${index + 1}',
                      flex: 1,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(orgData['name'],
                      flex: 3,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexActionsCell([
                    TextButton(
                        onPressed: () =>
                            launchURL(accredData['accreditationForm']),
                        child: Text(
                          accredData['formName'],
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                        ))
                  ],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor),
                  viewFlexTextCell(accredData['status'],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexActionsCell([
                    appproveRenewalButton(context,
                        onPress: () => showUploadCertificationDialog(
                            filteredAccreds[index].id)),
                    denyRenewalButton(context, onPress: () {
                      displayDeleteEntryDialog(context,
                          message:
                              'Are you sure you want to deny this org\'s accreditation request?',
                          deleteWord: 'Deny',
                          deleteEntry: () {});
                    }),
                  ],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor)
                ],
                borderColor: borderColor,
                isLastEntry: index == filteredAccreds.length - 1);
          }),
    );
  }

  void showUploadCertificationDialog(String accredID) {
    setState(() {
      _formCertificationSelectedFileBytes = null;
      _formCertificationSelectedFileExtension = null;
      _formCertificationSelectedFileName = null;
    });
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: ((context, setState) => AlertDialog(
                  content: loginBoxContainer(context,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            AutoSizeText(
                              'ORG CERTIFICATION',
                              style: blackBoldStyle(),
                            ),
                            Divider(thickness: 2),
                            Gap(20),
                            AutoSizeText(
                              'Upload the org certification here.',
                              style: blackBoldStyle(),
                            ),
                            Gap(10),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: 50,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black, width: 0.5),
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent),
                                  onPressed: () async {
                                    await pickFormAccreditation();
                                    setState(() {});
                                  },
                                  child: Text(
                                      _formCertificationSelectedFileBytes !=
                                              null
                                          ? _formCertificationSelectedFileName!
                                          : 'Click Here to Upload',
                                      style: TextStyle(color: Colors.black))),
                            ),
                            Gap(30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [registerActionButton('FINISH', () {})],
                            )
                          ],
                        ),
                      )),
                ))));
  }
}
