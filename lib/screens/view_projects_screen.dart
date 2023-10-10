import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

class ViewProjectsScreen extends StatefulWidget {
  const ViewProjectsScreen({super.key});

  @override
  State<ViewProjectsScreen> createState() => _ViewProjectsScreenState();
}

class _ViewProjectsScreenState extends State<ViewProjectsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> allProjects = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllProjects();
  }

  void getAllProjects() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final announcements =
          await FirebaseFirestore.instance.collection('projects').get();
      allProjects = announcements.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all projects: $error')));
    }
  }

  void deleteThisProject(DocumentSnapshot project) async {
    final scafffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      List<dynamic> images =
          (project.data() as Map<dynamic, dynamic>)['imageURLs'];

      await FirebaseFirestore.instance
          .collection('projects')
          .doc(project.id)
          .delete();

      if (images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('posts')
              .child('projects')
              .child(project.id);

          await storageRef.delete();
        }
      }
      getAllProjects();

      scafffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully deleted project!')));
    } catch (error) {
      scafffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error deleting project: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(),
        body: Row(children: [
          leftNavigator(context, 5),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.all(25),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      GoRouter.of(context)
                                          .go('/project/addProject');
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 88, 147, 201),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(11),
                                      child: AutoSizeText('NEW PROJECT',
                                          style: GoogleFonts.poppins(
                                              textStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    ))
                              ]),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            children: [
                              _announcementLabelRow(),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.65,
                                child: allProjects.isNotEmpty
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: allProjects.length,
                                        itemBuilder: (context, index) {
                                          double rowHeight = 50;
                                          Color entryColor = index % 2 == 0
                                              ? Colors.black
                                              : Colors.white;
                                          Map<dynamic, dynamic>
                                              announcementData =
                                              allProjects[index].data()
                                                  as Map<dynamic, dynamic>;
                                          return Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                color: index % 2 == 0
                                                    ? Colors.white
                                                    : Colors.grey,
                                                borderRadius: index ==
                                                        allProjects.length - 1
                                                    ? const BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(20),
                                                        bottomRight:
                                                            Radius.circular(20))
                                                    : null),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                    flex: 1,
                                                    child: Container(
                                                      height: rowHeight,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: index %
                                                                          2 !=
                                                                      0
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .grey)),
                                                      child: Center(
                                                          child: AutoSizeText(
                                                              '${index + 1}',
                                                              style: _projectEntryStyle(
                                                                  entryColor))),
                                                    )),
                                                Flexible(
                                                  flex: 2,
                                                  child: Container(
                                                    height: rowHeight,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: index % 2 !=
                                                                    0
                                                                ? Colors.white
                                                                : Colors.grey)),
                                                    child: Center(
                                                        child: AutoSizeText(
                                                            announcementData[
                                                                'title'],
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                _projectEntryStyle(
                                                                    entryColor))),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 5,
                                                  child: Container(
                                                    height: rowHeight,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: index % 2 !=
                                                                    0
                                                                ? Colors.white
                                                                : Colors.grey)),
                                                    child: Center(
                                                        child: AutoSizeText(
                                                            announcementData[
                                                                'content'],
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                _projectEntryStyle(
                                                                    entryColor))),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 2,
                                                  child: Container(
                                                    height: rowHeight,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: index % 2 !=
                                                                    0
                                                                ? Colors.white
                                                                : Colors.grey)),
                                                    child: Center(
                                                        child: AutoSizeText(
                                                            DateFormat(
                                                                    'dd MMM yyyy')
                                                                .format((announcementData[
                                                                            'projectDate']
                                                                        as Timestamp)
                                                                    .toDate()),
                                                            style:
                                                                _projectEntryStyle(
                                                                    entryColor))),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 2,
                                                  child: Container(
                                                    height: rowHeight,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: index % 2 !=
                                                                    0
                                                                ? Colors.white
                                                                : Colors.grey)),
                                                    child: Center(
                                                        child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              GoRouter.of(
                                                                      context)
                                                                  .goNamed(
                                                                      'editProject',
                                                                      pathParameters: {
                                                                    'projectID':
                                                                        allProjects[index]
                                                                            .id
                                                                  });
                                                            },
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .yellow),
                                                            child: const Icon(
                                                                Icons.edit,
                                                                color: Colors
                                                                    .white)),
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialog(
                                                                      content:
                                                                          const Text(
                                                                              'Are you sure you want to delete this project?'),
                                                                      actions: <Widget>[
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            GoRouter.of(context).pop();
                                                                          },
                                                                          child:
                                                                              const Text('Cancel'),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            GoRouter.of(context).pop();
                                                                            deleteThisProject(allProjects[index]);
                                                                          },
                                                                          child:
                                                                              const Text('Delete'),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });
                                                            },
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red),
                                                            child: const Icon(
                                                                Icons.delete,
                                                                color: Colors
                                                                    .white))
                                                      ],
                                                    )),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        })
                                    : Center(
                                        child: Text(
                                          'NO PROJECTS AVAILABLE',
                                          style: GoogleFonts.poppins(
                                              textStyle: const TextStyle(
                                                  fontSize: 38,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )),
          )
        ]));
  }

  Widget _announcementLabelRow() {
    double rowHeight = 50;
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: Colors.grey,
      ),
      child: Row(
        children: [
          Flexible(
              flex: 1,
              child: Container(
                height: rowHeight,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.white)),
                child: Center(
                    child: AutoSizeText('#',
                        style: _projectEntryStyle(Colors.white))),
              )),
          Flexible(
            flex: 2,
            child: Container(
              height: rowHeight,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Center(
                  child: AutoSizeText('Title',
                      style: _projectEntryStyle(Colors.white))),
            ),
          ),
          Flexible(
            flex: 5,
            child: Container(
              height: rowHeight,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Center(
                  child: AutoSizeText('Content',
                      style: _projectEntryStyle(Colors.white))),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              height: rowHeight,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Center(
                  child: AutoSizeText('Project Date',
                      style: _projectEntryStyle(Colors.white))),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              height: rowHeight,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Center(
                  child: AutoSizeText('Actions',
                      style: _projectEntryStyle(Colors.white))),
            ),
          )
        ],
      ),
    );
  }

  TextStyle _projectEntryStyle(Color thisColor) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
            color: thisColor, fontSize: 23, fontWeight: FontWeight.bold));
  }
}
