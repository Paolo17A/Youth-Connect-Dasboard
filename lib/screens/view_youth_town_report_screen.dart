import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_text_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';
import 'package:ywda_dashboard/widgets/youth_connect_textfield_widget.dart';

import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';

class ViewYouthTownReportScreen extends StatefulWidget {
  const ViewYouthTownReportScreen({super.key});

  @override
  State<ViewYouthTownReportScreen> createState() =>
      _ViewYouthTownReportScreenState();
}

class _ViewYouthTownReportScreenState extends State<ViewYouthTownReportScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;
  List<DocumentSnapshot> allUsers = [];
  List<DocumentSnapshot> orgDocs = [];
  List<String> towns = [];
  List<String> filteredTowns = [];
  final townController = TextEditingController();
  int pageNumber = 1;
  int maxPageNumber = 1;

  @override
  void initState() {
    super.initState();
    townController.addListener(onSearchTown);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasLoggedInUser()) {
        GoRouter.of(context).goNamed(GoRoutes.login);
        return;
      }
      if (!_isInitialized) getAllUsers();
    });
  }

  @override
  void dispose() {
    super.dispose();
    townController.dispose();
  }

  void getAllUsers() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'CLIENT')
          .get();
      allUsers = users.docs;

      towns.clear();
      for (var user in allUsers) {
        final userData = user.data() as Map<dynamic, dynamic>;
        String town = userData['city'];
        if (!towns.contains(town)) {
          towns.add(town);
        }
      }
      towns.sort((a, b) {
        return a.compareTo(b);
      });
      filteredTowns = List.from(towns);
      maxPageNumber = (filteredTowns.length / 10).ceil();

      List<dynamic> orgIDs = [];
      for (var user in allUsers) {
        final userData = user.data() as Map<dynamic, dynamic>;
        final orgID = userData['organization'];
        if (!orgIDs.contains(orgID)) {
          orgIDs.add(orgID);
        }
      }

      if (orgIDs.isNotEmpty) {
        final orgs = await FirebaseFirestore.instance
            .collection('orgs')
            .where(FieldPath.documentId, whereIn: orgIDs)
            .get();
        orgDocs = orgs.docs;
      }

      if (mounted)
        setState(() {
          _isLoading = false;
          _isInitialized = true;
        });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all users: $error')));
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  void onSearchTown() {
    setState(() {
      if (townController.text.isEmpty) {
        filteredTowns = towns;
      } else {
        filteredTowns = filteredTowns.where((thisTown) {
          return thisTown
              .toLowerCase()
              .trim()
              .contains(townController.text.toLowerCase().trim());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context),
      body: Row(
        children: [
          leftNavigator(context, 1.3),
          bodyWidgetMercuryBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  SingleChildScrollView(
                    child: horizontalPadding5Percent(
                        context,
                        Column(
                          children: [
                            _townReportHeaderWidget(),
                            _townReportContainerWidget()
                          ],
                        )),
                  )))
        ],
      ),
    );
  }

  Widget _townReportHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(children: [
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: YouthConnectTextField(
                text: 'Filter Towns',
                controller: townController,
                textInputType: TextInputType.text,
                displayPrefixIcon: null,
                onSubmit: () => onSearchTown()))
      ]),
    );
  }

  Widget _townReportContainerWidget() {
    return Column(
      children: [
        viewContentContainer(context,
            child: Column(
              children: [
                _townReportLabelRow(),
                filteredTowns.isNotEmpty
                    ? _userEntries()
                    : viewContentUnavailable(context,
                        text: 'NO TOWNS AVAILABLE')
              ],
            )),
        if (filteredTowns.length > 10) _navigatorButtons()
      ],
    );
  }

  Widget _townReportLabelRow() {
    return viewContentLabelRow(context, children: [
      viewFlexTextCell('#',
          flex: 1, backgroundColor: Colors.grey.withOpacity(0.5)),
      viewFlexTextCell('Town',
          flex: 4, backgroundColor: Colors.grey.withOpacity(0.5)),
      viewFlexTextCell('Number of Youth',
          flex: 2, backgroundColor: Colors.grey.withOpacity(0.5)),
      viewFlexTextCell('Actions',
          flex: 2, backgroundColor: Colors.grey.withOpacity(0.5))
    ]);
  }

  Widget _userEntries() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: SizedBox(
        height: 500,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: pageNumber == maxPageNumber && filteredTowns.length != 10
                ? filteredTowns.length % 10
                : 10,
            itemBuilder: (context, index) {
              Color backgroundColor =
                  index % 2 == 0 ? Colors.white : Colors.grey.withOpacity(0.5);
              Color borderColor =
                  index % 2 == 0 ? Colors.grey.withOpacity(0.5) : Colors.white;
              List<DocumentSnapshot> associatedUsers = allUsers.where(
                (user) {
                  final userData = user.data() as Map<dynamic, dynamic>;
                  return filteredTowns[index] == userData['city'];
                },
              ).toList();

              return viewContentEntryRow(context,
                  children: [
                    viewFlexTextCell('${(index + 1).toString()}',
                        flex: 1, backgroundColor: backgroundColor),
                    viewFlexTextCell(filteredTowns[index],
                        flex: 4, backgroundColor: backgroundColor),
                    viewFlexTextCell(associatedUsers.length.toString(),
                        flex: 2, backgroundColor: backgroundColor),
                    viewFlexActionsCell([
                      viewEntryPopUpButton(context,
                          onPress: () => showYouthResidentsDialog(
                              filteredTowns[index], associatedUsers)),
                    ], flex: 2, backgroundColor: backgroundColor)
                  ],
                  borderColor: borderColor,
                  isLastEntry: index == filteredTowns.length - 1);
            }),
      ),
    );
  }

  Widget _navigatorButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          previousPageButton(context,
              onPress: pageNumber == 1
                  ? null
                  : () {
                      if (pageNumber == 1) {
                        return;
                      }
                      setState(() {
                        pageNumber--;
                      });
                    }),
          Container(
            decoration:
                BoxDecoration(border: Border.all(color: CustomColors.darkBlue)),
            child: Padding(
              padding: const EdgeInsets.all(5.5),
              child: AutoSizeText(pageNumber.toString(),
                  style: TextStyle(color: CustomColors.darkBlue)),
            ),
          ),
          nextPageButton(context,
              onPress: pageNumber == maxPageNumber
                  ? null
                  : () {
                      if (pageNumber == maxPageNumber) {
                        return;
                      }
                      setState(() {
                        pageNumber++;
                      });
                    })
        ],
      ),
    );
  }

  void showYouthResidentsDialog(
      String town, List<DocumentSnapshot> associatedUsers) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [
                      AutoSizeText('Youth Residing in $town',
                          style: blackBoldStyle(size: 30)),
                      Gap(15),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              child: Center(
                                child: AutoSizeText('YOUTH',
                                    textAlign: TextAlign.center,
                                    style: blackBoldStyle(size: 17)),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              child: Center(
                                child: AutoSizeText('ORGANIZATION',
                                    textAlign: TextAlign.center,
                                    style: blackBoldStyle(size: 17)),
                              ),
                            )
                          ]),
                      SingleChildScrollView(
                        child: Column(
                            children: associatedUsers.map((user) {
                          final userData = user.data() as Map<dynamic, dynamic>;
                          String formattedName =
                              '${userData['firstName']} ${userData['lastName']}';
                          String organization = userData['organization'];
                          DocumentSnapshot orgDoc = orgDocs
                              .where((org) => org.id == organization)
                              .first;
                          final orgData =
                              orgDoc.data() as Map<dynamic, dynamic>;
                          String orgName = orgData['name'];
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  height: 80,
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  child: Center(
                                    child: AutoSizeText(formattedName,
                                        textAlign: TextAlign.center,
                                        style:
                                            GoogleFonts.poppins(fontSize: 20)),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  height: 80,
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  child: Center(
                                    child: AutoSizeText(orgName,
                                        textAlign: TextAlign.center,
                                        style:
                                            GoogleFonts.poppins(fontSize: 20)),
                                  ),
                                )
                              ]);
                        }).toList()),
                      )
                    ]),
                    ElevatedButton(
                        onPressed: () => GoRouter.of(context).pop(),
                        child: Text('CLOSE', style: whiteBoldStyle()))
                  ],
                ),
              ),
            ));
  }
}
