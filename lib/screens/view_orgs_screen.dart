import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/utils/delete_entry_dialog_util.dart';
import 'package:ywda_dashboard/widgets/custom_button_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_miscellaneous_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/dropdown_widget.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

class ViewOrgsScreen extends StatefulWidget {
  const ViewOrgsScreen({super.key});

  @override
  State<ViewOrgsScreen> createState() => _ViewOrgsScreenState();
}

class _ViewOrgsScreenState extends State<ViewOrgsScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;
  List<DocumentSnapshot> allOrgs = [];
  List<DocumentSnapshot> filteredOrgs = [];

  String _selectedCategory = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllOrgs();
  }

  void getAllOrgs() async {
    if (_isInitialized) {
      return;
    }
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final orgs = await FirebaseFirestore.instance.collection('orgs').get();
      allOrgs = orgs.docs;
      filteredOrgs = List.from(allOrgs);

      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all orgs: $error')));
    }
  }

  void _onSelectFilter() {
    setState(() {
      if (_selectedCategory.isEmpty) {
        filteredOrgs = allOrgs;
      } else {
        filteredOrgs = allOrgs.where((org) {
          final orgData = org.data()! as Map<dynamic, dynamic>;
          String orgNature = orgData['nature'].toString().toUpperCase();
          return orgNature == _selectedCategory;
        }).toList();
      }
    });
  }

  Future setOrgActiveState(String orgID, bool isActive) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseFirestore.instance
          .collection('orgs')
          .doc(orgID)
          .update({'isActive': isActive});
      _isInitialized = false;
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(isActive
              ? 'Successfully reinstated organization.'
              : 'Successfully suspended organization.')));
      getAllOrgs();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error setting org active state: $error')));
    }
  }

  //  BUILD WIDGET
  //============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
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
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: dropdownWidget(_selectedCategory, (selected) {
            _selectedCategory = selected!;
            _onSelectFilter();
          }, [
            '',
            'BROTHERHOOD',
            'COMMUNITY BASED',
            'MUSIC ARTS',
            'RELIGIOUS',
            'SCHOOL BASED',
            'SERVICE',
            'SOCIAL GROUP',
            'YOUTH AND LABOR',
          ], '', false),
        ),
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
    return viewContentContainer(context,
        child: Column(children: [
          _announcementLabelRow(),
          allOrgs.isNotEmpty
              ? _orgEntries()
              : viewContentUnavailable(context,
                  text: 'NO ORGANIZATIONS AVAILABLE')
        ]));
  }

  Widget _announcementLabelRow() {
    return viewContentLabelRow(context, children: [
      viewFlexTextCell('#',
          flex: 1,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell('Organization',
          flex: 3,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell('Number of Members',
          flex: 1,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell('Intro',
          flex: 2,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell('Nature of Organization',
          flex: 2,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell('Actions',
          flex: 2,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white)
    ]);
  }

  Widget _orgEntries() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredOrgs.length,
          itemBuilder: (context, index) {
            final orgData = filteredOrgs[index].data() as Map<dynamic, dynamic>;
            int memberCount = (orgData['members'] as List<dynamic>).length;
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
                  viewFlexTextCell(memberCount.toString(),
                      flex: 1,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(orgData['intro'],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(orgData['nature'],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexActionsCell([
                    editEntryButton(context,
                        onPress: () => GoRouter.of(context).goNamed('editOrg',
                            pathParameters: {'orgID': filteredOrgs[index].id})),
                    if (orgData['isActive'] == true)
                      deleteEntryButton(context, onPress: () {
                        displayDeleteEntryDialog(context,
                            message:
                                'Are you sure you want to suspend this organization?',
                            deleteEntry: () {
                          setOrgActiveState(filteredOrgs[index].id, false);
                        });
                      }),
                    if (orgData['isActive'] == false)
                      restoreEntryButton(context, onPress: () {
                        setOrgActiveState(filteredOrgs[index].id, true);
                      })
                  ],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor)
                ],
                borderColor: borderColor,
                isLastEntry: index == allOrgs.length - 1);
          }),
    );
  }
}
