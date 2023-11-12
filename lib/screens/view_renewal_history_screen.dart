import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ywda_dashboard/utils/url_util.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../widgets/custom_miscellaneous_widgets.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) getRenewalHistory();
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
      }
    });
  }

  Future getRenewalHistory() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      /*final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final userData = user.data() as Map<dynamic, dynamic>;
      List<dynamic> accredHistory = userData['renewalHistory'];*/
      final accreds = await FirebaseFirestore.instance
          .collection('accreditations')
          .where('orgHead', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      allRenewalRequests = accreds.docs;
      filteredRenewalRequests = List.from(allRenewalRequests);

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
      appBar: appBarWidget(context),
      body: Row(children: [
        leftNavigator(context, 2.1),
        bodyWidgetWhiteBG(
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
      ]),
    );
  }

  Widget _accredsContainerWidget() {
    return viewContentContainer(context,
        child: Column(
          children: [
            _accredsLabelRow(),
            filteredRenewalRequests.isNotEmpty
                ? _accredEntries()
                : viewContentUnavailable(context,
                    text: 'NO ACCREDITATION REQUESTS AVAILABLE')
          ],
        ));
  }

  Widget _accredsLabelRow() {
    return viewContentLabelRow(
      context,
      children: [
        viewFlexTextCell('#',
            flex: 1,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Name',
            flex: 3,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Accreditation Form',
            flex: 2,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        viewFlexTextCell('Status',
            flex: 2,
            backgroundColor: Colors.grey,
            borderColor: Colors.white,
            textColor: Colors.white),
        if (_selectedCategory == 'APPROVED')
          viewFlexTextCell('Certification',
              flex: 2,
              backgroundColor: Colors.grey,
              borderColor: Colors.white,
              textColor: Colors.white)
        else
          viewFlexTextCell('Actions',
              flex: 2,
              backgroundColor: Colors.grey,
              borderColor: Colors.white,
              textColor: Colors.white)
      ],
    );
  }

  Widget _accredEntries() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredRenewalRequests.length,
          itemBuilder: (context, index) {
            final accredData =
                filteredRenewalRequests[index].data() as Map<dynamic, dynamic>;
            final orgData =
                associatedOrgs[accredData['orgID']] as Map<dynamic, dynamic>;
            Color entryColor = index % 2 == 0 ? Colors.black : Colors.white;
            Color backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey;
            Color borderColor = index % 2 == 0 ? Colors.grey : Colors.white;

            return viewContentEntryRow(context,
                children: [
                  viewFlexTextCell('#${index + 1}',
                      flex: 1,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(orgData['name'],
                      flex: 3,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
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
                  ],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor),
                  viewFlexTextCell(accredData['status'],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexActionsCell([
                    if (accredData['status'] == 'APPROVED')
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.13,
                        child: TextButton(
                            onPressed: () =>
                                launchURL(accredData['certification']),
                            child: Text(
                              accredData['certificateName'],
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                  decoration: TextDecoration.underline),
                            )),
                      ),
                  ],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor)
                ],
                borderColor: borderColor,
                isLastEntry: index == filteredRenewalRequests.length - 1);
          }),
    );
  }
}
