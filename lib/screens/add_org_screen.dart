import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/youth_connect_textfield_widget.dart';
import 'package:ywda_dashboard/widgets/dropdown_widget.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../widgets/custom_text_widgets.dart';

class AddOrgScreen extends StatefulWidget {
  const AddOrgScreen({super.key});

  @override
  State<AddOrgScreen> createState() => _AddOrgScreenState();
}

class _AddOrgScreenState extends State<AddOrgScreen> {
  bool _isLoading = false;

  final _nameController = TextEditingController();
  String _nature = '';
  final _otherNatureController = TextEditingController();
  final _introController = TextEditingController();
  final _contactController = TextEditingController();
  final _socMedController = TextEditingController();

  Uint8List? selectedLogoFile;
  Uint8List? selectedCoverFile;

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _otherNatureController.dispose();
    _introController.dispose();
    _contactController.dispose();
    _socMedController.dispose();
  }

  //  IMAGE PICKER FUNCTIONS
  //============================================================================
  Future<void> _pickLogoImage() async {
    final pickedFile = await ImagePickerWeb.getImageAsBytes();
    if (pickedFile != null) {
      setState(() {
        selectedLogoFile = pickedFile;
      });
    }
  }

  Future<void> _pickCovermage() async {
    final pickedFile = await ImagePickerWeb.getImageAsBytes();
    if (pickedFile != null) {
      setState(() {
        selectedCoverFile = pickedFile;
      });
    }
  }
  //============================================================================

  //  UPLOAD FUNCTION
  //============================================================================
  void addNewOrg() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);

    //  GUARD VALIDATORS
    if (_nameController.text.isEmpty ||
        _introController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _socMedController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all fields.')));
      return;
    } else if (_nature == '' ||
        (_nature == 'OTHERS' && _otherNatureController.text.isEmpty)) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Please input a valid organization nature.')));
      return;
    } else if (!Uri.tryParse(_socMedController.text.trim())!.hasAbsolutePath) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please input a valid URL.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      //  Add Org Entry to FireStore
      String orgID = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance.collection('orgs').doc(orgID).set({
        'name': _nameController.text.trim(),
        'nature': _nature != 'OTHERS'
            ? _nature
            : _otherNatureController.text.trim().toUpperCase(),
        'contactDetails': _contactController.text.trim(),
        'intro': _introController.text.trim(),
        'socMed': _socMedController.text.trim(),
        'logoURL': '',
        'coverURL': '',
        'members': [],
        'isActive': true
      });

      //  Upload Logo to Firebase Storage
      if (selectedLogoFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('orgs')
            .child(orgID)
            .child('orgLogo');

        final uploadTask = storageRef.putData(selectedLogoFile!);
        final taskSnapshot = await uploadTask.whenComplete(() {});
        final downloadURL = await taskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('orgs')
            .doc(orgID)
            .update({'logoURL': downloadURL});
      }

      if (selectedCoverFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('orgs')
            .child(orgID)
            .child('orgCover');

        final uploadTask = storageRef.putData(selectedCoverFile!);
        final taskSnapshot = await uploadTask.whenComplete(() {});
        final downloadURL = await taskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('orgs')
            .doc(orgID)
            .update({'coverURL': downloadURL});
      }

      //  Done adding org to Firebase
      setState(() {
        _isLoading = false;
      });
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully added new organization!')));
      goRouter.go('/orgs');
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error adding new organization: $error')));
    }
  }

  //  WIDGET TREE
  //============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
        body: Row(children: [
          leftNavigator(context, 2),
          bodyWidgetWhiteBG(
              context,
              stackedLoadingContainer(
                  context,
                  _isLoading,
                  horizontalPadding5Percent(
                      context,
                      SingleChildScrollView(
                        child: Column(children: [
                          _newOrganizationHeaderWidget(),
                          _organizationNameWidget(),
                          _organizationNatureWidget(),
                          _organizationIntroWidget(),
                          _organizationContactDetailsWidget(),
                          _organizationSocMedWidget(),
                          _orgImageSelectorWidgets(),
                          const SizedBox(height: 30),
                          _submitButtonWidget()
                        ]),
                      ))))
        ]));
  }

  //  COMPONENT WIDGETS
  //============================================================================
  Widget _newOrganizationHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: AutoSizeText(
        'NEW ORGANIZATION',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
            textStyle: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ),
    );
  }

  Widget _organizationNameWidget() {
    return Column(children: [
      vertical10horizontal4(Row(
          children: [AutoSizeText('Organization Name', style: interSize19())])),
      YouthConnectTextField(
          text: 'Organization Name',
          controller: _nameController,
          textInputType: TextInputType.text,
          displayPrefixIcon: null),
      const SizedBox(height: 20)
    ]);
  }

  Widget _organizationNatureWidget() {
    List<String> natureOptions = [
      'BROTHERHOOD',
      'COMMUNITY BASED',
      'MUSIC ARTS',
      'RELIGIOUS',
      'SCHOOL BASED',
      'SERVICE',
      'SOCIAL GROUP',
      'YOUTH AND LABOR',
      'OTHERS'
    ];
    return Column(children: [
      Row(children: [
        AutoSizeText('Organization Nature', style: interSize19())
      ]),
      dropdownWidget(_nature, (selected) {
        setState(() {
          if (selected != null) {
            _nature = selected;
          }
        });
      }, natureOptions, 'Organization Nature', false),
      if (_nature == 'OTHERS')
        YouthConnectTextField(
            text: 'Organization Nature',
            controller: _otherNatureController,
            textInputType: TextInputType.text,
            displayPrefixIcon: null)
    ]);
  }

  Widget _organizationIntroWidget() {
    return Column(children: [
      vertical10horizontal4(Row(children: [
        AutoSizeText('Organization Intro', style: interSize19())
      ])),
      YouthConnectTextField(
          text: 'Organization Intro',
          controller: _introController,
          textInputType: TextInputType.multiline,
          displayPrefixIcon: null),
    ]);
  }

  Widget _organizationContactDetailsWidget() {
    return Column(children: [
      vertical10horizontal4(Row(
          children: [AutoSizeText('Contact Details', style: interSize19())])),
      YouthConnectTextField(
          text: 'Contact Details',
          controller: _contactController,
          textInputType: TextInputType.multiline,
          displayPrefixIcon: null)
    ]);
  }

  Widget _organizationSocMedWidget() {
    return Column(children: [
      vertical10horizontal4(Row(
          children: [AutoSizeText('Social Media Link', style: interSize19())])),
      YouthConnectTextField(
          text: 'Social Media',
          controller: _socMedController,
          textInputType: TextInputType.url,
          displayPrefixIcon: null)
    ]);
  }

  Widget _submitButtonWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: addNewOrg,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 88, 147, 201),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: AutoSizeText(
                'SUBMIT',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _orgImageSelectorWidgets() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_sizedBoxForLogo(), _sizedBoxForCover()]);
  }

  Widget _sizedBoxForLogo() {
    return imageSelectorSizedBox(context, [
      _uploadImageButton('UPLOAD LOGO IMAGE', _pickLogoImage),
      if (selectedLogoFile != null)
        _selectedMemoryImageDisplay(selectedLogoFile!, () {
          setState(() {
            selectedLogoFile = null;
          });
        })
    ]);
  }

  Widget _sizedBoxForCover() {
    return imageSelectorSizedBox(context, [
      _uploadImageButton('UPLOAD COVER IMAGE', _pickCovermage),
      if (selectedCoverFile != null)
        _selectedMemoryImageDisplay(selectedCoverFile!, () {
          setState(() {
            selectedCoverFile = null;
          });
        })
    ]);
  }

  Widget _uploadImageButton(String label, Function selectImage) {
    return ElevatedButton(
        onPressed: () {
          selectImage();
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 51, 86, 119),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: AutoSizeText(label,
              style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold))),
        ));
  }

  Widget _selectedMemoryImageDisplay(
      Uint8List? imageStream, Function deleteImage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                  width: 150, height: 150, child: Image.memory(imageStream!)),
              const SizedBox(height: 5),
              SizedBox(
                width: 90,
                child: ElevatedButton(
                    onPressed: () {
                      deleteImage();
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
    );
  }
  //============================================================================
}
