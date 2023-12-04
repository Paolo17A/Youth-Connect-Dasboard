import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ywda_dashboard/utils/go_router_util.dart';

import 'package:ywda_dashboard/utils/url_util.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/dropdown_widget.dart';

class ViewRenewalHistoryScreen extends StatefulWidget {
  const ViewRenewalHistoryScreen({super.key});

  @override
  State<ViewRenewalHistoryScreen> createState() =>
      _ViewRenewalHistoryScreenState();
}

class _ViewRenewalHistoryScreenState extends State<ViewRenewalHistoryScreen> {
  bool isLoading = true;
  bool isInitialized = false;
  List<DocumentSnapshot> allRenewalRequests = [];
  List<DocumentSnapshot> filteredRenewalRequests = [];
  Map<String, dynamic> associatedOrgs = {};
  String _selectedCategory = '';

  int pageNumber = 1;
  int maxPageNumber = 1;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasLoggedInUser()) {
        GoRouter.of(context).goNamed(GoRoutes.login);
        return;
      }
      if (!isInitialized) getRenewalHistory();
    });
  }

  void _onSelectFilter() {
    setState(() {
      if (_selectedCategory == 'NO FILTER') {
        filteredRenewalRequests = allRenewalRequests;
      } else {
        filteredRenewalRequests = allRenewalRequests.where((accred) {
          final accredData = accred.data() as Map<dynamic, dynamic>;
          String accredStatus = accredData['status'];
          return accredStatus == _selectedCategory;
        }).toList();
        filteredRenewalRequests = filteredRenewalRequests.reversed.toList();
      }
      maxPageNumber = (filteredRenewalRequests.length / 10).ceil();
    });
  }

  Future getRenewalHistory() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final accreds = await FirebaseFirestore.instance
          .collection('accreditations')
          .where('orgHead', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      allRenewalRequests = accreds.docs;
      filteredRenewalRequests = List.from(allRenewalRequests);
      filteredRenewalRequests = filteredRenewalRequests.reversed.toList();
      maxPageNumber = (filteredRenewalRequests.length / 10).ceil();

      setState(() {
        isLoading = false;
        isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error getting all org renewal requests: $error')));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: orgAppBarWidget(context),
      body: Row(children: [
        orgLeftNavigator(context, GoRoutes.orgRenewalHistory),
        bodyWidgetMercuryBG(
            context,
            switchedLoadingContainer(
                isLoading,
                SingleChildScrollView(
                  child: horizontalPadding5Percent(
                      context,
                      Column(children: [
                        _filterAccredsHeaderWidget(),
                        _accredsContainerWidget()
                      ])),
                )))
      ]),
    );
  }

  Widget _filterAccredsHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: dropdownWidget(_selectedCategory, (selected) {
            _selectedCategory = selected!;
            _onSelectFilter();
          }, ['NO FILTER', 'DISAPPROVED', 'PENDING', 'APPROVED'], '', false),
        ),
        AutoSizeText('${filteredRenewalRequests.length} entries',
            style: blackBoldStyle()),
      ]),
    );
  }

  Widget _accredsContainerWidget() {
    return Column(
      children: [
        viewContentContainer(context,
            child: Column(
              children: [
                _accredsLabelRow(),
                filteredRenewalRequests.isNotEmpty
                    ? _accredEntries()
                    : viewContentUnavailable(context,
                        text: 'NO ACCREDITATION REQUESTS AVAILABLE')
              ],
            )),
        if (filteredRenewalRequests.length > 10) _navigatorButtons()
      ],
    );
  }

  Widget _accredsLabelRow() {
    return viewContentLabelRow(
      context,
      children: [
        viewFlexTextCell('#',
            flex: 1, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('Accreditation Form',
            flex: 2, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('Status',
            flex: 2, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('Certification',
            flex: 2, backgroundColor: Colors.grey.withOpacity(0.5)),
        viewFlexTextCell('Approved/Disapproved Date',
            flex: 2, backgroundColor: Colors.grey.withOpacity(0.5))
      ],
    );
  }

  Widget _accredEntries() {
    return SizedBox(
      height: 500,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: pageNumber == maxPageNumber
              ? filteredRenewalRequests.length % 10
              : 10,
          itemBuilder: (context, index) {
            final accredData =
                filteredRenewalRequests[index + ((pageNumber - 1) * 10)].data()
                    as Map<dynamic, dynamic>;

            DateTime finalizedDate =
                (accredData['finalizedDate'] as Timestamp).toDate();

            String formattedDate = finalizedDate.year != 1970
                ? DateFormat('dd MMM yyyy').format(finalizedDate)
                : 'N/A';
            Color backgroundColor =
                index % 2 == 0 ? Colors.white : Colors.grey.withOpacity(0.5);
            Color borderColor =
                index % 2 == 0 ? Colors.grey.withOpacity(0.5) : Colors.white;

            return viewContentEntryRow(context,
                children: [
                  viewFlexTextCell('${(index + 1) + ((pageNumber - 1) * 10)}',
                      flex: 1, backgroundColor: backgroundColor),
                  viewFlexActionsCell([
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.13,
                      child: TextButton(
                          onPressed: () =>
                              launchURL(accredData['accreditationForm']),
                          child: Text(
                            accredData['formName'],
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                                decoration: TextDecoration.underline),
                          )),
                    )
                  ], flex: 2, backgroundColor: backgroundColor),
                  viewFlexTextCell(accredData['status'],
                      flex: 2, backgroundColor: backgroundColor),
                  viewFlexActionsCell([
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.13,
                      child: TextButton(
                          onPressed:
                              accredData['certification'].toString().isNotEmpty
                                  ? () => launchURL(accredData['certification'])
                                  : null,
                          child: Text(
                            accredData['certificateName'].toString().isNotEmpty
                                ? accredData['certificateName']
                                : 'N/A',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                                decoration: accredData['certificateName']
                                        .toString()
                                        .isNotEmpty
                                    ? TextDecoration.underline
                                    : null),
                          )),
                    ),
                  ], flex: 2, backgroundColor: backgroundColor),
                  viewFlexTextCell(formattedDate,
                      flex: 2, backgroundColor: backgroundColor),
                ],
                borderColor: borderColor,
                isLastEntry: index == filteredRenewalRequests.length - 1);
          }),
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
}
