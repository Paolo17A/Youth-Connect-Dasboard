import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:ywda_dashboard/utils/color_util.dart';
import 'package:ywda_dashboard/utils/go_router_util.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_text_widgets.dart';
import 'package:ywda_dashboard/widgets/youth_connect_textfield_widget.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_button_widgets.dart';

class EditOrgProjectScreen extends StatefulWidget {
  final String projectID;
  const EditOrgProjectScreen({super.key, required this.projectID});

  @override
  State<EditOrgProjectScreen> createState() => _EditOrgProjectScreenState();
}

class _EditOrgProjectScreenState extends State<EditOrgProjectScreen> {
  bool _isLoading = true;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  List<dynamic> imageURLs = [];
  List<Uint8List?> selectedItemImages = [];
  DateTime? _selectedDateStart;
  DateTime? _selectedDateEnd;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasLoggedInUser()) {
        GoRouter.of(context).goNamed(GoRoutes.login);
        return;
      }
      getThisProject();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _contentController.dispose();
  }

  void getThisProject() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final project = await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectID)
          .get();
      final projectData = project.data()!;

      _titleController.text = projectData['title'];
      _contentController.text = projectData['content'];
      imageURLs = projectData['imageURLs'];
      _selectedDateStart = (projectData['projectDate'] as Timestamp).toDate();
      _selectedDateEnd = (projectData['projectDateEnd'] as Timestamp).toDate();

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting this project: $error')));
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePickerWeb.getMultiImagesAsBytes();

    if (pickedFiles != null) {
      if (imageURLs.length + selectedItemImages.length + pickedFiles.length >
          5) {
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

  Future<void> _deleteImage(String projectID, String url, int index) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      imageURLs.remove(url);
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectID)
          .update({'imageURLs': imageURLs});

      /*final storageRef = FirebaseStorage.instance
          .ref()
          .child('posts')
          .child('projects')
          .child(widget.projectID);

      await storageRef.delete();*/

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error removing selected image: $error')));
      setState(() {
        _isLoading = false;
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

  void uploadChangesToProject() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all fields.')));
      return;
    }
    if (_titleController.text.length < 10) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content:
              Text('The project title must be at least 10 characters long.')));
      return;
    }
    if (_contentController.text.length < 30) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text(
              'The project content must be at least 30 characters long.')));
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
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectID)
          .update({
        'dateAdded': DateTime.now(),
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'projectDate': _selectedDateStart!,
        'projectDateEnd': _selectedDateEnd!,
      });
      if (selectedItemImages.isNotEmpty) {
        for (int i = 0; i < selectedItemImages.length; i++) {
          //  Upload all the selected image bytes to Firebase Storage and add them to a local List of URL strings
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('posts')
              .child('projects')
              .child(widget.projectID)
              .child('${generateRandomHexString(6)}.png');

          final uploadTask = storageRef.putData(selectedItemImages[i]!);
          final taskSnapshot = await uploadTask.whenComplete(() {});
          final downloadURL = await taskSnapshot.ref.getDownloadURL();

          //  Update Firestore to include the references of the uploaded images in Firebase Storage

          await FirebaseFirestore.instance
              .collection('projects')
              .doc(widget.projectID)
              .update({
            'imageURLs': FieldValue.arrayUnion([downloadURL])
          });
        }
      }

      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully edited this project!')));
      goRouter.go('/orgProjects');
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error editing project: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
        body: Row(
          children: [
            orgLeftNavigator(context, GoRoutes.orgProjects),
            bodyWidgetWhiteBG(
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
                                  _editProjectHeaderWidget(),
                                  _projectTitleWidget(),
                                  Gap(50),
                                  _projectContentWidget(),
                                  Padding(
                                    padding: const EdgeInsets.all(22),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _projectDateStartPickerWidget(),
                                        _projectDateEndPickerWidget(),
                                      ],
                                    ),
                                  ),
                                  _projectImageHandlerWidgets(),
                                  Gap(60),
                                  _projectSubmitButtonWidget()
                                ],
                              )),
                        ],
                      ),
                    )))
          ],
        ));
  }

  //  COMPONENT WIDGETS
  //============================================================================
  Widget _backButton() {
    return Row(children: [
      backToViewScreenButton(context,
          onPress: () => GoRouter.of(context).go('/orgProjects'))
    ]);
  }

  Widget _editProjectHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: AutoSizeText(
        'EDIT PROJECT',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(textStyle: blackBoldStyle(size: 38)),
      ),
    );
  }

  Widget _projectTitleWidget() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            AutoSizeText('Project Title',
                style: GoogleFonts.inter(
                    textStyle: const TextStyle(fontSize: 19))),
          ],
        ),
      ),
      YouthConnectTextField(
          text: 'Project Title',
          controller: _titleController,
          textInputType: TextInputType.text,
          displayPrefixIcon: null),
    ]);
  }

  Widget _projectContentWidget() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            AutoSizeText('Project Content',
                style: GoogleFonts.inter(
                    textStyle: const TextStyle(fontSize: 19))),
          ],
        ),
      ),
      YouthConnectTextField(
          text: 'Project Content',
          controller: _contentController,
          textInputType: TextInputType.multiline,
          displayPrefixIcon: null),
    ]);
  }

  Widget _projectDateStartPickerWidget() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () => _selectDateStart(context),
          style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.veniceBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: Padding(
              padding: const EdgeInsets.all(7),
              child: AutoSizeText(
                _selectedDateStart != null
                    ? DateFormat('MMM dd, yyyy').format(_selectedDateStart!)
                    : 'SELECT START DATE',
                style: GoogleFonts.poppins(textStyle: whiteBoldStyle(size: 15)),
              )),
        ));
  }

  Widget _projectDateEndPickerWidget() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () => _selectDateEnd(context),
          style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.veniceBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: Padding(
              padding: const EdgeInsets.all(7),
              child: AutoSizeText(
                _selectedDateEnd != null
                    ? DateFormat('MMM dd, yyyy').format(_selectedDateEnd!)
                    : 'SELECT END DATE',
                style: GoogleFonts.poppins(textStyle: whiteBoldStyle(size: 15)),
              )),
        ));
  }

  Widget _projectImageHandlerWidgets() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
                onPressed: _pickImages,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 51, 86, 119),
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
        const SizedBox(height: 30),
        Wrap(
          children: [
            if (imageURLs.isNotEmpty)
              Wrap(
                  children: imageURLs
                      .map((imageURL) => Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black)),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  squareBox150(Image.network(imageURL)),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: 90,
                                    child: ElevatedButton(
                                        onPressed: () => _deleteImage(
                                            widget.projectID, imageURLs[0], 0),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 24, 44, 63)),
                                        child: const Icon(Icons.delete)),
                                  )
                                ],
                              ),
                            ),
                          ))
                      .toList()),
            if (selectedItemImages.isNotEmpty)
              Wrap(
                children: selectedItemImages
                    .map((itemImage) => Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                squareBox150(Image.memory(itemImage!)),
                                const SizedBox(height: 5),
                                SizedBox(
                                  width: 90,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedItemImages.remove(itemImage);
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
                        ))
                    .toList(),
              ),
          ],
        )
      ]),
    );
  }

  Widget _projectSubmitButtonWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        ElevatedButton(
            onPressed: uploadChangesToProject,
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
      ]),
    );
  }
  //============================================================================
}
