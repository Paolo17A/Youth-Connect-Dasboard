import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/utils/custom_widgets.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

class ViewOrgsScreen extends StatefulWidget {
  const ViewOrgsScreen({super.key});

  @override
  State<ViewOrgsScreen> createState() => _ViewOrgsScreenState();
}

class _ViewOrgsScreenState extends State<ViewOrgsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> allOrgs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllOrgs();
  }

  void getAllOrgs() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final orgs = await FirebaseFirestore.instance.collection('orgs').get();
      allOrgs = orgs.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all orgs: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(),
        body: Row(children: [
          leftNavigator(context, 2),
          bodyWidgetWhiteBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  horizontalPadding5Percent(
                      context,
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          _newOrganizationHeaderWidget(),
                          _organizationsContainerWidget()
                        ],
                      ))))
        ]));
  }

  //  COMPONENT WIDGETS
  //============================================================================
  Widget _newOrganizationHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        ElevatedButton(
            onPressed: () {
              GoRouter.of(context).go('/orgs/addOrg');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 88, 147, 201),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: AutoSizeText('NEW ORGANIZATION',
                  style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold))),
            ))
      ]),
    );
  }

  Widget _organizationsContainerWidget() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        children: [
          _announcementLabelRow(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: allOrgs.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: allOrgs.length,
                    itemBuilder: (context, index) {
                      double rowHeight = 50;
                      Color entryTextColor =
                          index % 2 == 0 ? Colors.black : Colors.white;

                      Color entryBackgroundColor =
                          index % 2 == 0 ? Colors.white : Colors.grey;
                      Color entryBorderColor =
                          index % 2 != 0 ? Colors.white : Colors.grey;
                      Map<dynamic, dynamic> orgData =
                          allOrgs[index].data() as Map<dynamic, dynamic>;

                      String orgName = orgData['name'];
                      int memberCount =
                          (orgData['members'] as List<dynamic>).length;
                      String intro = orgData['intro'];
                      String nature = orgData['nature'];
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(color: entryBackgroundColor),
                        child: Row(
                          children: [
                            Flexible(
                                flex: 1,
                                child: Container(
                                  height: rowHeight,
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: entryBorderColor)),
                                  child: Center(
                                      child: AutoSizeText('#${index + 1}',
                                          style: _projectEntryStyle(
                                              entryTextColor))),
                                )),
                            Flexible(
                              flex: 3,
                              child: Container(
                                height: rowHeight,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: entryBorderColor)),
                                child: Center(
                                    child: AutoSizeText(orgName,
                                        style: _projectEntryStyle(
                                            entryTextColor))),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                height: rowHeight,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: entryBorderColor)),
                                child: Center(
                                    child: AutoSizeText(memberCount.toString(),
                                        style: _projectEntryStyle(
                                            entryTextColor))),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                height: rowHeight,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: entryBorderColor)),
                                child: Center(
                                    child: AutoSizeText(intro,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: _projectEntryStyle(
                                            entryTextColor))),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                height: rowHeight,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: entryBorderColor)),
                                child: Center(
                                    child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: AutoSizeText(nature,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style:
                                          _projectEntryStyle(entryTextColor)),
                                )),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                height: rowHeight,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: entryBorderColor)),
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          GoRouter.of(context).goNamed(
                                              'editOrg',
                                              pathParameters: {
                                                'orgID': allOrgs[index].id
                                              });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.yellow),
                                        child: const Icon(Icons.edit,
                                            color: Colors.white)),
                                    ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  content: const Text(
                                                      'Are you sure you want to suspend this organization?'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        GoRouter.of(context)
                                                            .pop();
                                                      },
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {},
                                                      child:
                                                          const Text('Suspend'),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        child: const Icon(Icons.delete,
                                            color: Colors.white))
                                  ],
                                )),
                              ),
                            )
                          ],
                        ),
                      );
                    })
                : _noOrgsAvailableWidget(),
          )
        ],
      ),
    );
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
            flex: 3,
            child: Container(
              height: rowHeight,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Center(
                  child: AutoSizeText('Organization',
                      style: _projectEntryStyle(Colors.white))),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              height: rowHeight,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Center(
                  child: AutoSizeText('Number of Members',
                      textAlign: TextAlign.center,
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
                  child: AutoSizeText('Intro',
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
                  child: AutoSizeText('Nature of Organization',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
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

  Widget _noOrgsAvailableWidget() {
    return Center(
      child: Text(
        'NO ORGANIZATIONS AVAILABLE',
        style: GoogleFonts.poppins(
            textStyle: const TextStyle(
                fontSize: 38,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  //  STYLING WIDGETS
  //============================================================================
  TextStyle _projectEntryStyle(Color thisColor) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
            color: thisColor, fontSize: 23, fontWeight: FontWeight.w400));
  }
  //============================================================================
}
