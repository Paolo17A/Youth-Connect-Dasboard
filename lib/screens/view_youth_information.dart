import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/delete_entry_dialog_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/dropdown_widget.dart';

class ViewYouthInformationScreen extends StatefulWidget {
  final String category;
  const ViewYouthInformationScreen({super.key, required this.category});

  @override
  State<ViewYouthInformationScreen> createState() =>
      _ViewYouthInformationScreenState();
}

class _ViewYouthInformationScreenState
    extends State<ViewYouthInformationScreen> {
  bool _isLoading = false;
  bool _isInitialized = false;
  List<DocumentSnapshot> allUsers = [];
  String _selectedCategory = 'NO FILTER';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllUsers();
  }

  Future getAllUsers() async {
    if (_isInitialized) {
      return;
    }
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'CLIENT')
          .get();
      allUsers = users.docs;

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all users: $error')));
    }
  }

  void _onSelectFilter() {
    GoRouter.of(context).goNamed('youthInformation',
        pathParameters: {'category': _selectedCategory});
  }

  Future setUserSuspendedState(String userID, bool isSuspended) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .update({'isSuspended': isSuspended});
      _isInitialized = false;
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(!isSuspended
              ? 'Successfully reinstated user.'
              : 'Successfully suspended user.')));
      getAllUsers();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error setting org active state: $error')));
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context),
      body: Row(
        children: [
          leftNavigator(context, 1),
          bodyWidgetWhiteBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  SingleChildScrollView(
                    child: horizontalPadding5Percent(
                        context,
                        Column(
                          children: [
                            _youthInformationHeaderWidget(),
                            if (_selectedCategory == 'NO FILTER')
                              _unfilteredYouthInformationContainerWidget()
                            else
                              _filteredYouthInformationContainerWidget()
                          ],
                        )),
                  )))
        ],
      ),
    );
  }

  Widget _youthInformationHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: dropdownWidget(_selectedCategory, (selected) {
            setState(() {
              _selectedCategory = selected!;
              _onSelectFilter();
            });
          }, ['NO FILTER', 'EDUCATION', 'TOWN', 'AGE REPORT', 'GENDER REPORT'],
              _selectedCategory, false),
        )
      ]),
    );
  }

  Widget _unfilteredYouthInformationContainerWidget() {
    return viewContentContainer(context,
        child: Column(
          children: [
            _unfilteredUsersLabelRow(),
            allUsers.isNotEmpty
                ? _unfilteredUserEntries()
                : viewContentUnavailable(context,
                    text: 'NO YOUTH INFORMATION AVAILABLE')
          ],
        ));
  }

  Widget _filteredYouthInformationContainerWidget() {
    return viewContentContainer(context,
        child: Column(
          children: [
            _filteredUsersLabelRow(),
            allUsers.isNotEmpty
                ? _filteredUserEntries()
                : viewContentUnavailable(context,
                    text: 'NO YOUTH INFORMATION AVAILABLE')
          ],
        ));
  }

  Widget _unfilteredUsersLabelRow() {
    return viewContentLabelRow(context, children: [
      viewFlexTextCell('Name',
          flex: 2,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell('Town',
          flex: 2,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell('Date of Birth',
          flex: 2,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell('Gender',
          flex: 2,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell('Status',
          flex: 2,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell('School',
          flex: 2,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell('Org',
          flex: 2,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell('Youth Category',
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

  Widget _filteredUsersLabelRow() {
    return viewContentLabelRow(context, children: [
      viewFlexTextCell('Name',
          flex: 2,
          backgroundColor: Colors.grey,
          borderColor: Colors.white,
          textColor: Colors.white),
      viewFlexTextCell(_selectedCategory,
          flex: 3,
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

  Widget _unfilteredUserEntries() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: allUsers.length,
          itemBuilder: (context, index) {
            final userData = allUsers[index].data() as Map<dynamic, dynamic>;
            String fullName = userData['fullName'];
            Color entryColor = index % 2 == 0 ? Colors.black : Colors.white;
            Color backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey;
            Color borderColor = index % 2 == 0 ? Colors.grey : Colors.white;

            return viewContentEntryRow(context,
                children: [
                  viewFlexTextCell(fullName.isNotEmpty ? fullName : 'N/A',
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(userData['city'],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(
                      DateFormat('dd MMM yyyy')
                          .format((userData['birthday'] as Timestamp).toDate()),
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(userData['gender'],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(userData['civilStatus'],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(userData['school'],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(userData['organization'],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexTextCell(userData['categoryGeneral'] ?? '',
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  viewFlexActionsCell([
                    editEntryButton(context, onPress: () {}),
                    if (userData['isSuspended'] == true)
                      restoreEntryButton(context, onPress: () {
                        setUserSuspendedState(allUsers[index].id, false);
                      })
                    else if (userData['isSuspended'] == false)
                      deleteEntryButton(context, onPress: () {
                        displayDeleteEntryDialog(context,
                            message:
                                'Are you sure you want to suspend this user?',
                            deleteEntry: () {
                          setUserSuspendedState(allUsers[index].id, true);
                        });
                      })
                  ],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor)
                ],
                borderColor: borderColor,
                isLastEntry: index == allUsers.length - 1);
          }),
    );
  }

  Widget _filteredUserEntries() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: allUsers.length,
          itemBuilder: (context, index) {
            final userData = allUsers[index].data() as Map<dynamic, dynamic>;
            String fullName = userData['fullName'];
            String education = userData['categorySpecific'];
            String city = userData['city'];
            int age =
                _calculateAge((userData['birthday'] as Timestamp).toDate());
            String gender = userData['gender'];

            Color entryColor = index % 2 == 0 ? Colors.black : Colors.white;
            Color backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey;
            Color borderColor = index % 2 == 0 ? Colors.grey : Colors.white;

            return viewContentEntryRow(context,
                children: [
                  viewFlexTextCell(fullName.isNotEmpty ? fullName : 'N/A',
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      textColor: entryColor),
                  if (_selectedCategory == 'EDUCATION')
                    viewFlexTextCell(education,
                        flex: 3,
                        backgroundColor: backgroundColor,
                        borderColor: borderColor,
                        textColor: entryColor)
                  else if (_selectedCategory == 'TOWN')
                    viewFlexTextCell(city,
                        flex: 3,
                        backgroundColor: backgroundColor,
                        borderColor: borderColor,
                        textColor: entryColor)
                  else if (_selectedCategory == 'AGE REPORT')
                    viewFlexTextCell('${age} years old',
                        flex: 3,
                        backgroundColor: backgroundColor,
                        borderColor: borderColor,
                        textColor: entryColor)
                  else if (_selectedCategory == 'GENDER REPORT')
                    viewFlexTextCell(gender,
                        flex: 3,
                        backgroundColor: backgroundColor,
                        borderColor: borderColor,
                        textColor: entryColor),
                  viewFlexActionsCell([
                    editEntryButton(context, onPress: () {}),
                    if (userData['isSuspended'] == true)
                      restoreEntryButton(context, onPress: () {
                        setUserSuspendedState(allUsers[index].id, false);
                      })
                    else if (userData['isSuspended'] == false)
                      deleteEntryButton(context, onPress: () {
                        displayDeleteEntryDialog(context,
                            message:
                                'Are you sure you want to suspend this user?',
                            deleteEntry: () {
                          setUserSuspendedState(allUsers[index].id, true);
                        });
                      })
                  ],
                      flex: 2,
                      backgroundColor: backgroundColor,
                      borderColor: borderColor)
                ],
                borderColor: borderColor,
                isLastEntry: index == allUsers.length - 1);
          }),
    );
  }
}
