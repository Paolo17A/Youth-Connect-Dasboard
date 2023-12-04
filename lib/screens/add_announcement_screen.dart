import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:ywda_dashboard/utils/go_router_util.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_text_widgets.dart';
import 'package:ywda_dashboard/widgets/youth_connect_textfield_widget.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/firebase_util.dart';
import '../widgets/custom_button_widgets.dart';

class AddAnnouncementScreen extends StatefulWidget {
  //final VoidCallback refreshCallback;
  const AddAnnouncementScreen({super.key /*, required this.refreshCallback*/});

  @override
  State<AddAnnouncementScreen> createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  Uint8List? currentSelectedFile;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasLoggedInUser()) {
        GoRouter.of(context).goNamed(GoRoutes.login);
        return;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _contentController.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePickerWeb.getImageAsBytes();
    if (pickedFile != null) {
      setState(() {
        currentSelectedFile = pickedFile;
      });
    }
  }

  void uploadNewAnnouncement() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    //  INPUT VALIDATORS
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all fields.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      String announcementID = DateTime.now().millisecondsSinceEpoch.toString();
      //  Create new announcement entry and upload to Firebase.
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(announcementID)
          .set({
        'dateAdded': DateTime.now(),
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'imageURLs': []
      });

      if (currentSelectedFile != null) {
        List<String> imageURLs = [];

        //  Upload all the selected image bytes to Firebase Storage and add them to a local List of URL strings
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('posts')
            .child('announcements')
            .child(announcementID);

        final uploadTask = storageRef.putData(currentSelectedFile!);
        final taskSnapshot = await uploadTask.whenComplete(() {});
        final downloadURL = await taskSnapshot.ref.getDownloadURL();
        imageURLs.add(downloadURL);

        //  Update Firestore to include the references of the uploaded images in Firebase Storage
        await FirebaseFirestore.instance
            .collection('announcements')
            .doc(announcementID)
            .update({'imageURLs': imageURLs});
      }

      setState(() {
        _isLoading = false;
      });

      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully created new announcement!')));
      //widget.refreshCallback();
      goRouter.go('/announcement');
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error uploading new announcement: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
        body: Row(
          children: [
            leftNavigator(context, 6),
            bodyWidgetMercuryBG(
                context,
                stackedLoadingContainer(
                  context,
                  _isLoading,
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _backButton(),
                        horizontalPadding5Percent(
                            context,
                            Column(
                              children: [
                                _announcementHeader(),
                                _announcementTitle(),
                                Gap(50),
                                _announcementContent(),
                                _announcementImage(),
                                Gap(60),
                                _announcementBottomButtons(),
                              ],
                            )),
                      ],
                    ),
                  ),
                ))
          ],
        ));
  }

  Widget _backButton() {
    return Row(children: [
      backToViewScreenButton(context,
          onPress: () => GoRouter.of(context).go('/announcement'))
    ]);
  }

  Widget _announcementHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: AutoSizeText(
        'NEW ANNOUNCEMENT',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(textStyle: blackBoldStyle(size: 38)),
      ),
    );
  }

  Widget _announcementTitle() {
    return Column(children: [
      vertical10horizontal4(Row(
        children: [
          AutoSizeText('Announcement Title', style: interSize19()),
          AutoSizeText('*', style: interSize19(textColor: Colors.red))
        ],
      )),
      YouthConnectTextField(
          text: 'Announcement Title',
          controller: _titleController,
          textInputType: TextInputType.text,
          displayPrefixIcon: null),
    ]);
  }

  Widget _announcementContent() {
    return Column(children: [
      vertical10horizontal4(Row(
        children: [
          AutoSizeText('Announcement Content', style: interSize19()),
          AutoSizeText('*', style: interSize19(textColor: Colors.red))
        ],
      )),
      YouthConnectTextField(
          text: 'Announcement Content',
          controller: _contentController,
          textInputType: TextInputType.multiline,
          displayPrefixIcon: null),
    ]);
  }

  Widget _announcementImage() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 51, 86, 119),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: AutoSizeText('UPLOAD IMAGE',
                      style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold))),
                )),
          ],
        ),
      ),
      if (currentSelectedFile != null)
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.memory(currentSelectedFile!)),
                const SizedBox(height: 5),
                SizedBox(
                  width: 90,
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentSelectedFile = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 24, 44, 63),
                      ),
                      child: const Icon(Icons.delete)),
                )
              ],
            ),
          ),
        ),
    ]);
  }

  Widget _announcementBottomButtons() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ElevatedButton(
          onPressed: uploadNewAnnouncement,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 88, 147, 201),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: AutoSizeText('SUBMIT',
                style:
                    GoogleFonts.poppins(textStyle: whiteBoldStyle(size: 18))),
          ))
    ]);
  }
}
