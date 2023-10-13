import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/youth_connect_textfield_widget.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../widgets/custom_text_widgets.dart';

class AddFormScreen extends StatefulWidget {
  const AddFormScreen({super.key});

  @override
  State<AddFormScreen> createState() => _AddFormScreenState();
}

class _AddFormScreenState extends State<AddFormScreen> {
  bool _isLoading = false;
  final _fileTitleController = TextEditingController();
  Uint8List? selectedFormFile;
  String? selectedFileName;
  String? selectedExtension;

  @override
  void dispose() {
    super.dispose();
    _fileTitleController.dispose();
  }

  Future pickFormFile() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          selectedFormFile = result.files.first.bytes;
          selectedExtension = result.files.first.extension;
          selectedFileName = result.files.first.name;
        });
      } else {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Selected File is null.')));
      }
    } catch (error) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Error picking file: $error')));
    }
  }

  Future addNewForm() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    if (_fileTitleController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please enter a file name.')));
      return;
    }
    if (selectedFormFile == null) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please select a file to upload')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      String formID = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName =
          '${_fileTitleController.text.trim()}.$selectedExtension';
      await FirebaseFirestore.instance
          .collection('forms')
          .doc(formID)
          .set({'fileName': fileName, 'fileURL': ''});

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('forms')
          .child(formID)
          .child(fileName);

      final uploadTask = storageRef.putData(selectedFormFile!);
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final downloadURL = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('forms')
          .doc(formID)
          .update({'fileURL': downloadURL});

      setState(() {
        _isLoading = false;
      });
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfull uploaded new form!')));
      goRouter.go('/forms');
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error adding new form: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context),
      body: Row(
        children: [
          leftNavigator(context, 3),
          bodyWidgetWhiteBG(
              context,
              stackedLoadingContainer(
                  context,
                  _isLoading,
                  horizontalPadding5Percent(
                      context,
                      SingleChildScrollView(
                          child: Column(children: [
                        _newFormHeaderWidget(),
                        _formTitleWidget(),
                        _fileSelectorWidget(),
                        const SizedBox(height: 30),
                        _submitButtonWidget()
                      ])))))
        ],
      ),
    );
  }

  Widget _newFormHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: AutoSizeText(
        'NEW Form',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
            textStyle: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ),
    );
  }

  Widget _formTitleWidget() {
    return Column(children: [
      vertical10horizontal4(
          Row(children: [AutoSizeText('Form Title', style: interSize19())])),
      YouthConnectTextField(
          text: 'Form Title',
          controller: _fileTitleController,
          textInputType: TextInputType.text,
          displayPrefixIcon: null),
      const SizedBox(height: 20)
    ]);
  }

  Widget _fileSelectorWidget() {
    return horizontalPadding5Percent(
      context,
      Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _uploadFormButton('SELECT FILE', pickFormFile),
            if (selectedFileName != null)
              Text(selectedFileName!,
                  style: const TextStyle(color: Colors.black))
          ]),
    );
  }

  Widget _submitButtonWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: addNewForm,
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

  Widget _uploadFormButton(String label, Function selectImage) {
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
}
