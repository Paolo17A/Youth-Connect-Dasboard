import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_textfield_widget.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

class EditAnnouncementScreen extends StatefulWidget {
  final String announcementID;
  const EditAnnouncementScreen({super.key, required this.announcementID});

  @override
  State<EditAnnouncementScreen> createState() => _EditAnnouncementScreenState();
}

class _EditAnnouncementScreenState extends State<EditAnnouncementScreen> {
  bool _isLoading = true;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  List<dynamic> imageURLs = [];
  Uint8List? currentSelectedFile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getThisAnnouncement();
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _contentController.dispose();
  }

  void getThisAnnouncement() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final announcement = await FirebaseFirestore.instance
          .collection('announcements')
          .doc(widget.announcementID)
          .get();
      final announcementData = announcement.data()!;

      _titleController.text = announcementData['title'];
      _contentController.text = announcementData['content'];
      imageURLs = announcementData['imageURLs'];

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error getting this announcement data: $error')));
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

  Future<void> _deleteImage(
      String announcementID, String url, int index) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      imageURLs.remove(url);
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(announcementID)
          .update({'imageURLs': imageURLs});

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('posts')
          .child('announcements')
          .child(announcementID);

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

  void uploadChangesToAnnouncement() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    //  INPUT VALIDATORS
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all fields.')));
      return;
    } else if (_titleController.text.length < 10) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text(
              'The announcement title must be at least 10 characters long.')));
      return;
    } else if (_contentController.text.length < 30) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text(
              'The announcement content must be at least 30 characters long.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      //  Create new announcement entry and upload to Firebase.
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(widget.announcementID)
          .update({
        'dateAdded': DateTime.now(),
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
      });

      if (currentSelectedFile != null) {
        //  Upload all the selected image bytes to Firebase Storage and add them to a local List of URL strings
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('posts')
            .child('announcements')
            .child(widget.announcementID);

        final uploadTask = storageRef.putData(currentSelectedFile!);
        final taskSnapshot = await uploadTask.whenComplete(() {});
        final downloadURL = await taskSnapshot.ref.getDownloadURL();
        imageURLs.add(downloadURL);

        //  Update Firestore to include the references of the uploaded images in Firebase Storage
        await FirebaseFirestore.instance
            .collection('announcements')
            .doc(widget.announcementID)
            .update({'imageURLs': imageURLs});
      }

      setState(() {
        _isLoading = false;
      });

      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully edited this announcement!')));
      goRouter.go('/announcement');
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error editing this announcement: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(),
        body: Row(
          children: [
            leftNavigator(context, 6),
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
                              'EDIT ANNOUNCEMENT',
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
                                AutoSizeText('Announcement Title',
                                    style: GoogleFonts.inter(
                                        textStyle:
                                            const TextStyle(fontSize: 19))),
                              ],
                            ),
                          ),
                          YouthConnectTextField(
                              text: 'Announcement Title',
                              controller: _titleController,
                              textInputType: TextInputType.text,
                              displayPrefixIcon: null),
                          const SizedBox(height: 50),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 4),
                            child: Row(
                              children: [
                                AutoSizeText('Announcement Content',
                                    style: GoogleFonts.inter(
                                        textStyle:
                                            const TextStyle(fontSize: 19))),
                              ],
                            ),
                          ),
                          YouthConnectTextField(
                              text: 'Announcement Content',
                              controller: _contentController,
                              textInputType: TextInputType.multiline,
                              displayPrefixIcon: null),
                          Padding(
                            padding: const EdgeInsets.all(22),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedButton(
                                    onPressed: _pickImage,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
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
                          if (currentSelectedFile == null &&
                              imageURLs.isNotEmpty)
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
                                        child: Image.network(imageURLs[0])),
                                    const SizedBox(height: 5),
                                    SizedBox(
                                      width: 90,
                                      child: ElevatedButton(
                                          onPressed: () => _deleteImage(
                                              widget.announcementID,
                                              imageURLs[0],
                                              0),
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
                                    onPressed: uploadChangesToAnnouncement,
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
