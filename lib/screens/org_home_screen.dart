import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ywda_dashboard/utils/go_router_util.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_button_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_miscellaneous_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_text_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/url_util.dart';
import '../widgets/custom_padding_widgets.dart';

class OrgHomeScreen extends StatefulWidget {
  const OrgHomeScreen({super.key});

  @override
  State<OrgHomeScreen> createState() => _OrgHomeScreenState();
}

class _OrgHomeScreenState extends State<OrgHomeScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;
  List<DocumentSnapshot> allAnnouncements = [];
  bool _isAccredited = false;
  String orgID = '';
  String _accreditationStatus = '';
  Uint8List? _formAccreditationSelectedFileBytes;
  String? _formAccreditationSelectedFileName;
  String? _formAccreditationSelectedFileExtension;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasLoggedInUser()) {
        GoRouter.of(context).goNamed(GoRoutes.login);
        return;
      }
      if (!_isInitialized) initializeOrgHome();
    });
  }

  void initializeOrgHome() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final userData = user.data() as Map<dynamic, dynamic>;
      orgID = userData['organization'];

      final org =
          await FirebaseFirestore.instance.collection('orgs').doc(orgID).get();
      final orgData = org.data() as Map<dynamic, dynamic>;
      _isAccredited = orgData['isAccredited'];
      _accreditationStatus = orgData['accreditationStatus'];

      final announcements =
          await FirebaseFirestore.instance.collection('announcements').get();
      allAnnouncements = announcements.docs;
      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all announcements: $error')));
    }
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
          _formAccreditationSelectedFileBytes = result.files.first.bytes;
          _formAccreditationSelectedFileName = result.files.first.name;
          _formAccreditationSelectedFileExtension =
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

  void uploadAccreditationForm() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    if (_formAccreditationSelectedFileExtension == null) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Please upload a filled out accreditation from.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      goRouter.pop();
      String accreditationID = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('accreditations')
          .child(accreditationID)
          .child(
              'accreditationForm.${_formAccreditationSelectedFileExtension!}');
      UploadTask uploadTask =
          storageRef.putData(_formAccreditationSelectedFileBytes!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String accreditationFormDownloadURL =
          await taskSnapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('accreditations')
          .doc(accreditationID)
          .set({
        'orgHead': FirebaseAuth.instance.currentUser!.uid,
        'orgID': orgID,
        'formName': _formAccreditationSelectedFileName,
        'accreditationForm': accreditationFormDownloadURL,
        'certification': '',
        'certificateName': '',
        'finalizeDate': DateTime(1970),
        'status': 'PENDING'
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'renewalHistory': FieldValue.arrayUnion([accreditationID])
      });

      await FirebaseFirestore.instance
          .collection('orgs')
          .doc(orgID)
          .update({'accreditationStatus': 'PENDING'});

      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully applied for accreditation!')));
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error uploading accreditation form: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: orgAppBarWidget(context),
      body: Row(
        children: [
          orgLeftNavigator(context, GoRoutes.orgHome),
          bodyWidgetMercuryBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _orgRenewalWidgets(),
                          Gap(40),
                          _announcementsContainer()
                        ],
                      ),
                    ),
                  )))
        ],
      ),
    );
  }

  Widget _orgRenewalWidgets() {
    return Row(
      children: [
        orgDashboardWidget(context,
            label: _isAccredited ? 'ACCREDITED' : 'UNACCREDITED',
            buttonLabel: 'Renew',
            displayIcon:
                Image.asset('assets/images/icons/organization.png', scale: 2),
            onPress: () {
          if (!_isAccredited &&
              (_accreditationStatus == '' ||
                  _accreditationStatus == 'DISAPPROVED')) {
            _displayRenewOrgDialog();
          }
        }, willHideButton: _isAccredited && _accreditationStatus == 'APPROVED'),
        orgDashboardWidget(context,
            label: _accreditationStatus.isNotEmpty
                ? _accreditationStatus
                : 'NO AVAILABLE ACCREDITATION STATUS',
            buttonLabel: 'History',
            displayIcon: Icon(
              _accreditationStatus == 'APPROVED' || _accreditationStatus == ''
                  ? Icons.thumb_up
                  : _accreditationStatus == 'DISAPPROVED'
                      ? Icons.thumb_down
                      : Icons.pending,
              color: _accreditationStatus == 'APPROVED' ||
                      _accreditationStatus == ''
                  ? Colors.green
                  : _accreditationStatus == 'DISAPPROVED'
                      ? Colors.red
                      : Colors.yellow,
            ),
            onPress: () => GoRouter.of(context).go('/orgRenewalHistory'))
      ],
    );
  }

  Widget _announcementsContainer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(offset: Offset(0, 3), color: Colors.grey.withOpacity(0.5))
      ], color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(children: [
              AutoSizeText(
                'Announcements',
                style: blackBoldStyle(),
              ),
            ]),
            allAnnouncements.isNotEmpty
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.53,
                    child: SingleChildScrollView(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: allAnnouncements.length,
                          itemBuilder: (context, index) {
                            //  Local variables for better readability
                            final announcement = allAnnouncements[index].data()
                                as Map<dynamic, dynamic>;
                            String title = announcement['title'];
                            String content = announcement['content'];
                            Timestamp dateAdded = announcement['dateAdded'];
                            DateTime dateAnnounced = dateAdded.toDate();
                            String formattedDateAnnounced =
                                DateFormat('dd MMM yyyy').format(dateAnnounced);
                            List<dynamic> imageURLs = announcement['imageURLs'];
                            return GestureDetector(
                                onTap: () {},
                                child: announcementEntryContainer(
                                    allAnnouncements[index],
                                    imageURLs,
                                    formattedDateAnnounced,
                                    title,
                                    content));
                          }),
                    ),
                  )
                : Center(
                    child:
                        Text('No ANNOUNCEMENTS YET', style: blackBoldStyle()))
          ],
        ),
      ),
    );
  }

  Widget announcementEntryContainer(
      DocumentSnapshot announcementDoc,
      List<dynamic> imageURLs,
      String formattedDateAnnounced,
      String title,
      String content) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Container(
            height: 100,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: ElevatedButton(
              onPressed: () => showAnnouncementDialog(announcementDoc),
              style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.mercury,
                  foregroundColor: Colors.black),
              child: Row(
                children: [
                  if (imageURLs.isNotEmpty)
                    allPadding4pix(_miniNetworkImage(imageURLs[0])),
                  announcementEntryTextContainer(
                      imageURLs, formattedDateAnnounced, title, content)
                ],
              ),
            )));
  }

  Widget announcementEntryTextContainer(List<dynamic> imageURLs,
      String formattedDateAnnounced, String title, String content) {
    return SizedBox(
      width: imageURLs.isNotEmpty
          ? MediaQuery.of(context).size.width * 0.45
          : MediaQuery.of(context).size.width * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          allPadding4pix(
              Text(formattedDateAnnounced, style: TextStyle(fontSize: 14))),
          horizontalPadding5pix(Text(title, style: titleTextStyle())),
          horizontalPadding5pix(SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            height: 40,
            child: Text(content, softWrap: true, style: contentTextStyle()),
          ))
        ],
      ),
    );
  }

  Widget _miniNetworkImage(String src) {
    return Container(
      width: 80,
      height: 80,
      child: Image.network(src),
    );
  }

  void showAnnouncementDialog(DocumentSnapshot announcementDoc) {
    showDialog(
        context: context,
        builder: (context) {
          final announcementData =
              announcementDoc.data() as Map<dynamic, dynamic>;
          String title = announcementData['title'];
          String content = announcementData['content'];
          Timestamp dateAdded = announcementData['dateAdded'];
          DateTime dateAnnounced = dateAdded.toDate();
          String formattedDateAnnounced =
              DateFormat('dd MMM yyyy').format(dateAnnounced);
          List<dynamic> imageURLs = announcementData['imageURLs'];
          return AlertDialog(
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(title, style: blackBoldStyle(size: 40)),
                          AutoSizeText(formattedDateAnnounced,
                              style: TextStyle(color: Colors.black)),
                          SingleChildScrollView(
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: AutoSizeText(content,
                                    style: blackThinStyle())),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: imageURLs
                                .map((image) => Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                          border: Border.all(),
                                          image: DecorationImage(
                                              image: NetworkImage(image))),
                                    ))
                                .toList()),
                      ),
                      Gap(15),
                      ElevatedButton(
                          onPressed: () => GoRouter.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.darkBlue),
                          child: allPadding20Pix(
                              AutoSizeText('CLOSE', style: whiteBoldStyle()))),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  void _displayRenewOrgDialog() {
    setState(() {
      _formAccreditationSelectedFileBytes = null;
      _formAccreditationSelectedFileExtension = null;
      _formAccreditationSelectedFileName = null;
    });
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: ((context, setState) => AlertDialog(
                  content: loginBoxContainer(context,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              'You can now apply for accredition in our office.',
                              style: blackBoldStyle(),
                            ),
                            Divider(thickness: 2),
                            allPadding8Pix(Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  'Step 1. Download the accreditation form below.',
                                  style: blackBoldStyle(),
                                ),
                                TextButton(
                                    onPressed: () {
                                      launchURL(
                                          'https://firebasestorage.googleapis.com/v0/b/ywda-dfc54.appspot.com/o/YDAaccred-form-2021.docx?alt=media&token=80b29287-44a7-4cb8-a8db-c315fd6d041c');
                                    },
                                    child: AutoSizeText(
                                      'ACCREDITATION FORM',
                                      style: TextStyle(
                                          color: Colors.black,
                                          decoration: TextDecoration.underline),
                                    )),
                                Gap(25),
                                AutoSizeText(
                                  'Step 2. Upload the filled out form here.',
                                  style: blackBoldStyle(),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
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
                                          _formAccreditationSelectedFileBytes !=
                                                  null
                                              ? _formAccreditationSelectedFileName!
                                              : 'Click Here to Upload',
                                          style:
                                              TextStyle(color: Colors.black))),
                                ),
                                Gap(30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    registerActionButton('FINISH',
                                        () async => uploadAccreditationForm())
                                  ],
                                )
                              ],
                            ))
                          ],
                        ),
                      )),
                ))));
  }
}
