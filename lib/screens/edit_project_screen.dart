import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_widgets.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_textfield_widget.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

class EditProjectScreen extends StatefulWidget {
  final String projectID;
  const EditProjectScreen({super.key, required this.projectID});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  bool _isLoading = true;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  List<dynamic> imageURLs = [];
  Uint8List? currentSelectedFile;
  DateTime? _selectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getThisProject();
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
      _selectedDate = (projectData['projectDate'] as Timestamp).toDate();

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting this project: $error')));
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePickerWeb.getImageAsBytes();
    if (pickedFile != null) {
      setState(() {
        currentSelectedFile = pickedFile;
      });
    }
  }

  Future<void> _deleteImage(String projectID, String url, int index) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      imageURLs.remove(url);
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectID)
          .update({'imageURLs': imageURLs});

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('posts')
          .child('projects')
          .child(projectID);

      await storageRef.delete();

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate!,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _selectedDate = picked;
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
    } else if (_titleController.text.length < 10) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content:
              Text('The project title must be at least 10 characters long.')));
      return;
    } else if (_contentController.text.length < 30) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text(
              'The project content must be at least 30 characters long.')));
      return;
    } else if (_selectedDate == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Please select a date for this project.')));
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectID)
          .update({
        'dateAdded': DateTime.now(),
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'projectDate': _selectedDate!
      });
      if (currentSelectedFile != null) {
        //  Upload all the selected image bytes to Firebase Storage and add them to a local List of URL strings
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('posts')
            .child('projects')
            .child(widget.projectID);

        final uploadTask = storageRef.putData(currentSelectedFile!);
        final taskSnapshot = await uploadTask.whenComplete(() {});
        final downloadURL = await taskSnapshot.ref.getDownloadURL();
        imageURLs.add(downloadURL);

        //  Update Firestore to include the references of the uploaded images in Firebase Storage
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(widget.projectID)
            .update({'imageURLs': imageURLs});
      }
      setState(() {
        _isLoading = true;
      });
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully edited this project!')));
      goRouter.go('/project');
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
            leftNavigator(context, 5),
            bodyWidgetWhiteBG(
                context,
                stackedLoadingContainer(
                    context,
                    _isLoading,
                    horizontalPadding5Percent(
                        context,
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              _editProjectHeaderWidget(),
                              _projectTitleWidget(),
                              const SizedBox(height: 50),
                              _projectContentWidget(),
                              Padding(
                                padding: const EdgeInsets.all(22),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _projectDatePickerWidget(),
                                    _projectImageHandlerWidgets()
                                  ],
                                ),
                              ),
                              const SizedBox(height: 60),
                              _projectSubmitButtonWidget()
                            ],
                          ),
                        ))))
          ],
        ));
  }

  //  COMPONENT WIDGETS
  //============================================================================
  Widget _editProjectHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: AutoSizeText(
        'EDIT PROJECT',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
            textStyle: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
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

  Widget _projectDatePickerWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () => _selectDate(context),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 51, 86, 119),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: AutoSizeText(
                _selectedDate != null
                    ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                    : 'SELECT DATE',
                style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold))),
          )),
    );
  }

  Widget _projectImageHandlerWidgets() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        Row(
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
        const SizedBox(height: 30),
        if (currentSelectedFile != null)
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  squareBox150(Image.memory(currentSelectedFile!)),
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
                          backgroundColor:
                              const Color.fromARGB(255, 24, 44, 63),
                        ),
                        child: const Icon(Icons.delete)),
                  )
                ],
              ),
            ),
          ),
        if (currentSelectedFile == null && imageURLs.isNotEmpty)
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  squareBox150(Image.network(imageURLs[0])),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 90,
                    child: ElevatedButton(
                        onPressed: () =>
                            _deleteImage(widget.projectID, imageURLs[0], 0),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 24, 44, 63),
                        ),
                        child: const Icon(Icons.delete)),
                  )
                ],
              ),
            ),
          )
      ]),
    );
  }

  Widget _projectSubmitButtonWidget() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ElevatedButton(
          onPressed: uploadChangesToProject,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 88, 147, 201),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: AutoSizeText('SUBMIT',
                style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold))),
          ))
    ]);
  }
  //============================================================================
}
