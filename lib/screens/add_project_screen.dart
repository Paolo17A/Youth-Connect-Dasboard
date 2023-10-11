import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/youth_connect_textfield_widget.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  Uint8List? currentSelectedFile;
  DateTime? _selectedDate;

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _selectedDate = picked;
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
        'projectDate': _selectedDate!,
        'participants': []
      });

      if (currentSelectedFile != null) {
        List<String> imageURLs = [];

        //  Upload all the selected image bytes to Firebase Storage and add them to a local List of URL strings
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('posts')
            .child('projects')
            .child(projectID);

        final uploadTask = storageRef.putData(currentSelectedFile!);
        final taskSnapshot = await uploadTask.whenComplete(() {});
        final downloadURL = await taskSnapshot.ref.getDownloadURL();
        imageURLs.add(downloadURL);

        //  Update Firestore to include the references of the uploaded images in Firebase Storage
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(projectID)
            .update({'imageURLs': imageURLs});
      }

      setState(() {
        _isLoading = false;
      });

      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully created new announcement!')));
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
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Stack(children: [
                Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 50),
                            child: AutoSizeText(
                              'NEW PROJECT',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 4),
                            child: Row(
                              children: [
                                AutoSizeText('Project Title',
                                    style: GoogleFonts.inter(
                                        textStyle:
                                            const TextStyle(fontSize: 19))),
                              ],
                            ),
                          ),
                          YouthConnectTextField(
                              text: 'Project Title',
                              controller: _titleController,
                              textInputType: TextInputType.text,
                              displayPrefixIcon: null),
                          const SizedBox(height: 50),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 4),
                            child: Row(
                              children: [
                                AutoSizeText('Project Content',
                                    style: GoogleFonts.inter(
                                        textStyle:
                                            const TextStyle(fontSize: 19))),
                              ],
                            ),
                          ),
                          YouthConnectTextField(
                              text: 'Project Content',
                              controller: _contentController,
                              textInputType: TextInputType.multiline,
                              displayPrefixIcon: null),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(22),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () => _selectDate(context),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 51, 86, 119),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(7),
                                          child: AutoSizeText(
                                              _selectedDate != null
                                                  ? DateFormat('MMM dd, yyyy')
                                                      .format(_selectedDate!)
                                                  : 'SELECT DATE',
                                              style: GoogleFonts.poppins(
                                                  textStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold))),
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
                                        onPressed: _pickImage,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 51, 86, 119),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(7),
                                          child: AutoSizeText('UPLOAD IMAGE',
                                              style: GoogleFonts.poppins(
                                                  textStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (currentSelectedFile != null)
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black)),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    SizedBox(
                                        width: 150,
                                        height: 150,
                                        child:
                                            Image.memory(currentSelectedFile!)),
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
                                                const Color.fromARGB(
                                                    255, 24, 44, 63),
                                          ),
                                          child: const Icon(Icons.delete)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 60),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    onPressed: uploadNewProject,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 88, 147, 201),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(11),
                                      child: AutoSizeText('SUBMIT',
                                          style: GoogleFonts.poppins(
                                              textStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    ))
                              ]),
                        ],
                      ),
                    )),
                if (_isLoading)
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(child: CircularProgressIndicator()))
              ]),
            )
          ],
        ));
  }
}
