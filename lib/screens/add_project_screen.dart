import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:ywda_dashboard/utils/color_util.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_text_widgets.dart';
import 'package:ywda_dashboard/widgets/youth_connect_textfield_widget.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_button_widgets.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  //Uint8List? currentSelectedFile;
  DateTime? _selectedDateStart;
  DateTime? _selectedDateEnd;
  List<Uint8List?> selectedItemImages = [];

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

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePickerWeb.getMultiImagesAsBytes();

    if (pickedFiles != null) {
      if (selectedItemImages.length + pickedFiles.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('You may only have up a max of five images')));
        return;
      }
      setState(() {
        for (var image in pickedFiles) {
          selectedItemImages.add(image);
        }
      });
    }
  }

  Future<void> _selectDateStart(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _selectedDateStart = picked;
      });
    }
  }

  Future<void> _selectDateEnd(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _selectedDateEnd = picked;
      });
    }
  }

  void uploadNewProject() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all fields.')));
      return;
    }
    if (_selectedDateStart == null && _selectedDateEnd == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content:
              Text('Please select the start and end dates for this project.')));
      return;
    }
    if (_selectedDateStart!.isAfter(_selectedDateEnd!)) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('The end date must be after the start date.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      String projectID = DateTime.now().millisecondsSinceEpoch.toString();
      //  Create new announcement entry and upload to Firebase.
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectID)
          .set({
        'dateAdded': DateTime.now(),
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'imageURLs': [],
        'organizer': FirebaseAuth.instance.currentUser!.uid,
        'projectDate': _selectedDateStart!,
        'projectDateEnd': _selectedDateEnd!,
        'participants': []
      });

      if (selectedItemImages.isNotEmpty) {
        for (int i = 0; i < selectedItemImages.length; i++) {
          //  Upload all the selected image bytes to Firebase Storage and add them to a local List of URL strings
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('posts')
              .child('projects')
              .child(projectID)
              .child('${generateRandomHexString(6)}.png');

          final uploadTask = storageRef.putData(selectedItemImages[i]!);
          final taskSnapshot = await uploadTask.whenComplete(() {});
          final downloadURL = await taskSnapshot.ref.getDownloadURL();

          //  Update Firestore to include the references of the uploaded images in Firebase Storage

          await FirebaseFirestore.instance
              .collection('projects')
              .doc(projectID)
              .update({
            'imageURLs': FieldValue.arrayUnion([downloadURL])
          });
        }
      }

      setState(() {
        _isLoading = false;
      });

      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully created new project!')));
      goRouter.go('/project');
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error creating new project: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
        body: Row(
          children: [
            leftNavigator(context, 5),
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
                                  _newProjectHeader(),
                                  _projectTitle(),
                                  Gap(50),
                                  _projectContent(),
                                  _projectDatesSelect(),
                                  _projectImages(),
                                  Gap(60),
                                  _submitButton(),
                                  Gap(40)
                                ],
                              )),
                        ],
                      ),
                    )))
          ],
        ));
  }

  Widget _backButton() {
    return Row(children: [
      backToViewScreenButton(context,
          onPress: () => GoRouter.of(context).go('/project'))
    ]);
  }

  Widget _newProjectHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: AutoSizeText(
        'NEW PROJECT',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(textStyle: blackBoldStyle(size: 38)),
      ),
    );
  }

  Widget _projectTitle() {
    return Column(children: [
      vertical10horizontal4(Row(
        children: [
          AutoSizeText('Project Title',
              style:
                  GoogleFonts.inter(textStyle: const TextStyle(fontSize: 19))),
          AutoSizeText('*', style: interSize19(textColor: Colors.red))
        ],
      )),
      YouthConnectTextField(
          text: 'Project Title',
          controller: _titleController,
          textInputType: TextInputType.text,
          displayPrefixIcon: null),
    ]);
  }

  Widget _projectContent() {
    return Column(children: [
      vertical10horizontal4(Row(
        children: [
          AutoSizeText('Project Content',
              style:
                  GoogleFonts.inter(textStyle: const TextStyle(fontSize: 19))),
          AutoSizeText('*', style: interSize19(textColor: Colors.red))
        ],
      )),
      YouthConnectTextField(
          text: 'Project Content',
          controller: _contentController,
          textInputType: TextInputType.multiline,
          displayPrefixIcon: null),
    ]);
  }

  Widget _projectDatesSelect() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                  onPressed: () => _selectDateStart(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.veniceBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: AutoSizeText(
                        _selectedDateStart != null
                            ? DateFormat('MMM dd, yyyy')
                                .format(_selectedDateStart!)
                            : 'SELECT START DATE',
                        style: GoogleFonts.poppins(
                            textStyle: whiteBoldStyle(size: 15))),
                  )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                  onPressed: () => _selectDateEnd(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.veniceBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: AutoSizeText(
                        _selectedDateEnd != null
                            ? DateFormat('MMM dd, yyyy')
                                .format(_selectedDateEnd!)
                            : 'SELECT END DATE',
                        style: GoogleFonts.poppins(
                            textStyle: whiteBoldStyle(size: 15))),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _projectImages() {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                  onPressed: _pickImages,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.veniceBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: AutoSizeText('UPLOAD IMAGES',
                        style: GoogleFonts.poppins(
                            textStyle: whiteBoldStyle(size: 15))),
                  )),
            ],
          ),
          if (selectedItemImages.isNotEmpty)
            Wrap(
                children: selectedItemImages
                    .map((itemBytes) => Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black)),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 150,
                                      height: 150,
                                      child: Image.memory(itemBytes!)),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: 90,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedItemImages
                                                .remove(itemBytes);
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 24, 44, 63),
                                        ),
                                        child: const Icon(Icons.delete)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ))
                    .toList()),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ElevatedButton(
          onPressed: uploadNewProject,
          style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.veniceBlue,
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
