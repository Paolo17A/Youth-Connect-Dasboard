import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ywda_dashboard/utils/color_util.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_miscellaneous_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/delete_entry_dialog_util.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/dropdown_widget.dart';

class ViewUserAccountsScreen extends StatefulWidget {
  const ViewUserAccountsScreen({super.key});

  @override
  State<ViewUserAccountsScreen> createState() => _ViewUserAccountsScreenState();
}

class _ViewUserAccountsScreenState extends State<ViewUserAccountsScreen> {
  bool _isLoading = false;
  bool _isInitialized = false;
  List<DocumentSnapshot> allUsers = [];
  List<DocumentSnapshot> filteredUsers = [];
  String _selectedCategory = 'NO FILTER';

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
      getAllUsers();
    });
  }

  void _onSelectFilter() {
    setState(() {
      if (_selectedCategory == 'NO FILTER') {
        filteredUsers = allUsers;
      } else if (_selectedCategory == 'YOUTH') {
        filteredUsers = allUsers.where((user) {
          final userData = user.data()! as Map<dynamic, dynamic>;
          String userType = userData['userType'].toString().toUpperCase();
          return userType == 'CLIENT';
        }).toList();
      } else {
        filteredUsers = allUsers.where((user) {
          final userData = user.data()! as Map<dynamic, dynamic>;
          String userType = userData['userType'].toString().toUpperCase();
          return userType == _selectedCategory;
        }).toList();
      }
      maxPageNumber = (filteredUsers.length / 10).ceil();
    });
  }

  Future getAllUsers() async {
    if (_isInitialized) {
      return;
    }
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isNotEqualTo: 'ADMIN')
          .get();
      allUsers = users.docs;
      allUsers.sort((a, b) {
        final firstNameA =
            (a.data() as Map<dynamic, dynamic>)['firstName'] as String;
        final firstNameB =
            (b.data() as Map<dynamic, dynamic>)['firstName'] as String;
        return firstNameA.compareTo(firstNameB);
      });
      filteredUsers = List.from(allUsers);
      maxPageNumber = (filteredUsers.length / 10).ceil();

      for (var user in filteredUsers) {
        final userData = user.data() as Map<dynamic, dynamic>;
        if (!userData.containsKey('isSuspended')) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .update({'isSuspended': false});
        }
      }
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all users: $error')));
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context),
      body: Row(
        children: [
          leftNavigator(context, 4),
          bodyWidgetWhiteBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  SingleChildScrollView(
                    child: horizontalPadding5Percent(
                        context,
                        Column(
                          children: [
                            _newUserHeaderWidget(),
                            _usersContainerWidget()
                          ],
                        )),
                  )))
        ],
      ),
    );
  }

  Widget _newUserHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: dropdownWidget(_selectedCategory, (selected) {
            setState(() {
              _selectedCategory = selected!;
              _onSelectFilter();
            });
          }, ['NO FILTER', 'YOUTH', 'ORG HEAD'], _selectedCategory, false),
        ),
        AutoSizeText('${filteredUsers.length} entries',
            style: blackBoldStyle()),
        /*ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 88, 147, 201),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: AutoSizeText('NEW USER',
                  style:
                      GoogleFonts.poppins(textStyle: whiteBoldStyle(size: 18))),
            ))*/
      ]),
    );
  }

  Widget _usersContainerWidget() {
    return Column(
      children: [
        viewContentContainer(context,
            child: Column(
              children: [
                _usersLabelRow(),
                filteredUsers.isNotEmpty
                    ? _userEntries()
                    : viewContentUnavailable(context,
                        text: 'NO USERS AVAILABLE')
              ],
            )),
        if (filteredUsers.length > 10) _navigatorButtons()
      ],
    );
  }

  Widget _usersLabelRow() {
    return viewContentLabelRow(context, children: [
      viewFlexTextCell('Name',
          flex: 3, backgroundColor: Colors.grey.withOpacity(0.5)),
      viewFlexTextCell('Username',
          flex: 3, backgroundColor: Colors.grey.withOpacity(0.5)),
      viewFlexTextCell('Type',
          flex: 2, backgroundColor: Colors.grey.withOpacity(0.5)),
      viewFlexTextCell('Actions',
          flex: 2, backgroundColor: Colors.grey.withOpacity(0.5))
    ]);
  }

  Widget _userEntries() {
    return SizedBox(
      height: 500,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount:
              pageNumber == maxPageNumber ? filteredUsers.length % 10 : 10,
          itemBuilder: (context, index) {
            final userData = filteredUsers[index + ((pageNumber - 1) * 10)]
                .data() as Map<dynamic, dynamic>;
            String fullName = userData['fullName'] ??
                '${userData['firstName']} ${userData['middleName']} ${userData['lastName']}';
            Color backgroundColor =
                index % 2 == 0 ? Colors.white : Colors.grey.withOpacity(0.5);
            Color borderColor =
                index % 2 == 0 ? Colors.grey.withOpacity(0.5) : Colors.white;

            return viewContentEntryRow(context,
                children: [
                  viewFlexTextCell(fullName.isNotEmpty ? fullName : 'N/A',
                      flex: 3, backgroundColor: backgroundColor),
                  viewFlexTextCell(userData['username'],
                      flex: 3, backgroundColor: backgroundColor),
                  viewFlexTextCell(
                      userData['userType'] == 'CLIENT'
                          ? 'YOUTH'
                          : userData['userType'],
                      flex: 2,
                      backgroundColor: backgroundColor),
                  viewFlexActionsCell([
                    //viewEntryPopUpButton(context, onPress: () {}),
                    editEntryButton(context,
                        onPress: () => GoRouter.of(context)
                                .goNamed('editYouth', pathParameters: {
                              'returnPoint': '4',
                              'youthID':
                                  allUsers[index + ((pageNumber - 1) * 10)].id
                            })),
                    if (userData['isSuspended'] == true)
                      restoreEntryButton(context, onPress: () {
                        setUserSuspendedState(
                            filteredUsers[index + ((pageNumber - 1) * 10)].id,
                            false);
                      })
                    else if (userData['isSuspended'] == false)
                      deleteEntryButton(context, onPress: () {
                        displayDeleteEntryDialog(context,
                            message:
                                'Are you sure you want to suspend this user?',
                            deleteWord: 'Delete', deleteEntry: () {
                          setUserSuspendedState(
                              filteredUsers[index + ((pageNumber - 1) * 10)].id,
                              true);
                        });
                      })
                  ], flex: 2, backgroundColor: backgroundColor)
                ],
                borderColor: borderColor,
                isLastEntry: index == filteredUsers.length - 1);
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
              padding: const EdgeInsets.all(14),
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
