import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/color_util.dart';
import '../utils/delete_entry_dialog_util.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../utils/youth_information_dialog_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/dropdown_widget.dart';

class ViewYouthGenderReportScreen extends StatefulWidget {
  const ViewYouthGenderReportScreen({super.key});

  @override
  State<ViewYouthGenderReportScreen> createState() =>
      _ViewYouthGenderReportState();
}

class _ViewYouthGenderReportState extends State<ViewYouthGenderReportScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;
  List<DocumentSnapshot> allUsers = [];
  List<DocumentSnapshot> filteredUsers = [];
  List<DocumentSnapshot> orgDocs = [];
  String _selectedCategory = 'NO FILTER';

  int pageNumber = 1;
  int maxPageNumber = 1;

  @override
  void initState() {
    super.initState();
  }

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
      } else if (_selectedCategory == 'OTHERS') {
        filteredUsers = allUsers.where((user) {
          final userData = user.data()! as Map<dynamic, dynamic>;
          String gender = userData['gender'];
          return gender != 'WOMAN' &&
              gender != 'MAN' &&
              gender != 'NON-BINARY' &&
              gender != 'TRANSGENDER' &&
              gender != 'INTERSEX';
        }).toList();
      } else {
        filteredUsers = allUsers.where((user) {
          final userData = user.data()! as Map<dynamic, dynamic>;
          return userData['gender'] == _selectedCategory;
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
          .where('userType', isEqualTo: 'CLIENT')
          .get();
      allUsers = users.docs;
      filteredUsers = List.from(allUsers);
      maxPageNumber = (filteredUsers.length / 10).ceil();
      allUsers.sort((a, b) {
        final firstNameA =
            (a.data() as Map<dynamic, dynamic>)['firstName'] as String;
        final firstNameB =
            (b.data() as Map<dynamic, dynamic>)['firstName'] as String;
        return firstNameA.compareTo(firstNameB);
      });

      List<dynamic> orgIDs = [];
      for (var user in allUsers) {
        final userData = user.data() as Map<dynamic, dynamic>;
        String organization = userData['organization'];
        if (!orgIDs.contains(organization)) {
          orgIDs.add(organization);
        }
      }

      final orgs = await FirebaseFirestore.instance
          .collection('orgs')
          .where(FieldPath.documentId, whereIn: orgIDs)
          .get();
      orgDocs = orgs.docs;
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all users: $error')));
    }
  }

  Future deleteUser(DocumentSnapshot userDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      //  Remove client from related orgs
      final QuerySnapshot relevantOrgsQuery = await FirebaseFirestore.instance
          .collection('orgs')
          .where('members', arrayContains: userDoc.id)
          .get();

      List<DocumentSnapshot> relevantOrgs = relevantOrgsQuery.docs;

      for (DocumentSnapshot orgSnapshot in relevantOrgs) {
        // Use FieldValue.arrayRemove to remove userDoc.id from 'members' field
        await orgSnapshot.reference.update({
          'members': FieldValue.arrayRemove([userDoc.id])
        });
      }

      //  Remove client from related projects
      final QuerySnapshot relevantProjectsQuery = await FirebaseFirestore
          .instance
          .collection('projects')
          .where('participants', arrayContains: userDoc.id)
          .get();

      List<DocumentSnapshot> relevantParticipants = relevantProjectsQuery.docs;

      for (DocumentSnapshot participantSnapshot in relevantParticipants) {
        // Use FieldValue.arrayRemove to remove userDoc.id from 'members' field
        await participantSnapshot.reference.update({
          'participants': FieldValue.arrayRemove([userDoc.id])
        });
      }

      //  Proceed with acutal account deletion
      final adminData = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final adminEmail = adminData['email'];
      final adminPassword = adminData['password'];
      await FirebaseAuth.instance.signOut();

      final userData = userDoc.data() as Map<dynamic, dynamic>;
      final userEmail = userData['email'];
      final userPassword = userData['password'];

      final userToDelete = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: userPassword);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userToDelete.user!.uid)
          .delete();

      await FirebaseAuth.instance.currentUser!.delete();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: adminEmail, password: adminPassword);
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully deleted this user!')));
      _isInitialized = false;
      getAllUsers();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error setting org active state: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context),
      body: Row(
        children: [
          leftNavigator(context, 1.2),
          bodyWidgetMercuryBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  SingleChildScrollView(
                    child: horizontalPadding5Percent(
                        context,
                        Column(
                          children: [
                            _genderReportHeaderWidget(),
                            _genderReportContainerWidget()
                          ],
                        )),
                  )))
        ],
      ),
    );
  }

  Widget _genderReportHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: dropdownWidget(_selectedCategory, (selected) {
            setState(() {
              _selectedCategory = selected!;
              _onSelectFilter();
            });
          }, [
            'NO FILTER',
            'WOMAN',
            'MAN',
            'NON-BINARY',
            'TRANSGENDER',
            'INTERSEX',
            'OTHERS'
          ], _selectedCategory, false),
        ),
        AutoSizeText('${filteredUsers.length} entries',
            style: blackBoldStyle()),
      ]),
    );
  }

  Widget _genderReportContainerWidget() {
    return Column(
      children: [
        viewContentContainer(context,
            child: Column(
              children: [
                _genderReportLabelRow(),
                filteredUsers.isNotEmpty
                    ? _userEntries()
                    : viewContentUnavailable(context,
                        text: 'NO YOUTH INFORMATION AVAILABLE')
              ],
            )),
        if (filteredUsers.length > 10) _navigatorButtons()
      ],
    );
  }

  Widget _genderReportLabelRow() {
    return viewContentLabelRow(context, children: [
      viewFlexTextCell('#',
          flex: 1, backgroundColor: Colors.grey.withOpacity(0.5)),
      viewFlexTextCell('Name',
          flex: 3, backgroundColor: Colors.grey.withOpacity(0.5)),
      viewFlexTextCell('Gender',
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
            itemCount: pageNumber == maxPageNumber && filteredUsers.length != 10
                ? filteredUsers.length % 10
                : 10,
            itemBuilder: (context, index) {
              final userData = filteredUsers[index + ((pageNumber - 1) * 10)]
                  .data() as Map<dynamic, dynamic>;
              String fullName =
                  '${userData['firstName']} ${userData['lastName']}';
              String gender = userData['gender'];

              Color backgroundColor =
                  index % 2 == 0 ? Colors.white : Colors.grey.withOpacity(0.5);
              Color borderColor =
                  index % 2 == 0 ? Colors.grey.withOpacity(0.5) : Colors.white;
              DocumentSnapshot orgDoc = orgDocs
                  .where((org) => org.id == userData['organization'])
                  .first;
              String orgName = (orgDoc.data() as Map<dynamic, dynamic>)['name'];
              return viewContentEntryRow(context,
                  children: [
                    viewFlexTextCell('${(index + 1).toString()}',
                        flex: 1, backgroundColor: backgroundColor),
                    viewFlexTextCell(fullName.isNotEmpty ? fullName : 'N/A',
                        flex: 3, backgroundColor: backgroundColor),
                    viewFlexTextCell(gender,
                        flex: 2, backgroundColor: backgroundColor),
                    viewFlexActionsCell([
                      viewEntryPopUpButton(context,
                          onPress: () => showYouthInformationDialog(
                              context,
                              filteredUsers[index + ((pageNumber - 1) * 10)],
                              orgName)),
                      editEntryButton(context,
                          onPress: () => GoRouter.of(context)
                                  .goNamed('editYouth', pathParameters: {
                                'returnPoint': '1.2',
                                'youthID': filteredUsers[
                                        index + ((pageNumber - 1) * 10)]
                                    .id
                              })),
                      deleteEntryButton(context, onPress: () {
                        displayDeleteEntryDialog(context,
                            message:
                                'Are you sure you want to delete this user?',
                            deleteWord: 'Delete',
                            deleteEntry: () => deleteUser(filteredUsers[
                                index + ((pageNumber - 1) * 10)]));
                      })
                    ], flex: 2, backgroundColor: backgroundColor)
                  ],
                  borderColor: borderColor,
                  isLastEntry: index == filteredUsers.length - 1);
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
}
