import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../utils/firebase_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_container_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/left_navigation_bar_widget.dart';
import '../widgets/youth_connect_textfield_widget.dart';

class EditOrgHeadScreen extends StatefulWidget {
  final String orgHeadID;
  final String orgID;
  const EditOrgHeadScreen(
      {super.key, required this.orgHeadID, required this.orgID});

  @override
  State<EditOrgHeadScreen> createState() => _EditOrgHeadScreenState();
}

enum RegisterStates { MEMBERSHIP, ORGANIZATION }

class _EditOrgHeadScreenState extends State<EditOrgHeadScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;
  RegisterStates currentRegisterState = RegisterStates.MEMBERSHIP;

  Map<dynamic, dynamic> orgHeadData = {};
  Map<dynamic, dynamic> orgData = {};

  //  Membership Text Fields
  final _familyNameController = TextEditingController();
  final _givenNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _headEmailAddressController = TextEditingController();
  final _adviserLastNameController = TextEditingController();
  final _adviserGivenNameController = TextEditingController();
  final _adviserMiddleNameController = TextEditingController();
  final _adviserContactNumberController = TextEditingController();
  final _adviseremailAddressController = TextEditingController();

  //  Org Fields
  final _orgNameController = TextEditingController();
  final _orgTelephoneController = TextEditingController();
  final _orgMobileController = TextEditingController();
  final _orgIslandController = TextEditingController();
  final _orgProvinceController = TextEditingController();
  final _orgBarangayController = TextEditingController();
  final _orgMajorClassificationController = TextEditingController();
  final _orgEmailAddressController = TextEditingController();
  final _orgInitialMemberCountController = TextEditingController();
  DateTime? dateEstablished;
  final _orgRegionController = TextEditingController();
  final _orgMunicipalityController = TextEditingController();
  final _orgSubclassificationController = TextEditingController();
  final _orgDescriptionController = TextEditingController();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasLoggedInUser()) {
        GoRouter.of(context).go('/login');
        return;
      }
      if (!_isInitialized) getOrgHeadData();
    });
  }

  void handlePreviousButton() {
    setState(() {
      switch (currentRegisterState) {
        case RegisterStates.MEMBERSHIP:
          GoRouter.of(context).go('/orgHeads');
          break;
        case RegisterStates.ORGANIZATION:
          currentRegisterState = RegisterStates.MEMBERSHIP;
          break;
        default:
          break;
      }
    });
  }

  void handleNextButton() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      switch (currentRegisterState) {
        case RegisterStates.MEMBERSHIP:
          if (_familyNameController.text.isEmpty ||
              _givenNameController.text.isEmpty ||
              _middleNameController.text.isEmpty ||
              _contactNumberController.text.isEmpty ||
              _headEmailAddressController.text.isEmpty ||
              _adviserLastNameController.text.isEmpty ||
              _adviserGivenNameController.text.isEmpty ||
              _adviserMiddleNameController.text.isEmpty ||
              _adviserContactNumberController.text.isEmpty ||
              _adviseremailAddressController.text.isEmpty) {
            scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Please fill up all fields.')));
            return;
          } else if (_contactNumberController.text.length != 11 ||
              _adviserContactNumberController.text.length != 11) {
            scaffoldMessenger.showSnackBar(const SnackBar(
                content: Text('Contact numbers must be exactly 11 digits.')));
            return;
          } else if (!_headEmailAddressController.text.contains('@') ||
              !_headEmailAddressController.text.contains('.com') ||
              !_adviseremailAddressController.text.contains('@') ||
              !_adviseremailAddressController.text.contains('.com')) {
            scaffoldMessenger.showSnackBar(const SnackBar(
                content: Text('Please enter valid email addresses.')));
            return;
          }
          currentRegisterState = RegisterStates.ORGANIZATION;
          break;
        case RegisterStates.ORGANIZATION:
          if (_orgNameController.text.isEmpty ||
              _orgTelephoneController.text.isEmpty ||
              _orgMobileController.text.isEmpty ||
              _orgBarangayController.text.isEmpty ||
              _orgMajorClassificationController.text.isEmpty ||
              _orgEmailAddressController.text.isEmpty ||
              _orgInitialMemberCountController.text.isEmpty ||
              dateEstablished == null ||
              _orgMunicipalityController.text.isEmpty ||
              _orgSubclassificationController.text.isEmpty ||
              _orgDescriptionController.text.isEmpty) {
            scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Please fill up all fields.')));
            return;
          } else if (_orgTelephoneController.text.length != 8 ||
              int.tryParse(_orgTelephoneController.text) == null) {
            scaffoldMessenger.showSnackBar(const SnackBar(
                content:
                    Text('Please input a valid 8 digit telephone number')));
            return;
          } else if (_orgMobileController.text.length != 11 ||
              int.tryParse(_orgMobileController.text) == null) {
            scaffoldMessenger.showSnackBar(const SnackBar(
                content: Text('Please input a valid 11 digit mobile number')));
            return;
          }
          _editOrgHead();
          break;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        dateEstablished = picked;
      });
    }
  }

  Future getOrgHeadData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final orgHead = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.orgHeadID)
          .get();
      orgHeadData = orgHead.data() as Map<dynamic, dynamic>;

      final org = await FirebaseFirestore.instance
          .collection('orgs')
          .doc(widget.orgID)
          .get();
      orgData = org.data() as Map<dynamic, dynamic>;

      _familyNameController.text = orgHeadData['lastName'];
      _givenNameController.text = orgHeadData['firstName'];
      _middleNameController.text = orgHeadData['middleName'];
      _contactNumberController.text = orgHeadData['contactNumber'];
      _headEmailAddressController.text = orgHeadData['orgHeadEmail'];
      _adviserLastNameController.text = orgHeadData['adviserLastName'];
      _adviserGivenNameController.text = orgHeadData['adviserFirstName'];
      _adviserMiddleNameController.text = orgHeadData['adviserMiddleName'];
      _adviserContactNumberController.text =
          orgHeadData['adviserContactNumber'];
      _adviseremailAddressController.text = orgHeadData['adviserEmail'];

      _orgNameController.text = orgData['name'];
      _orgTelephoneController.text = orgData['telephone'];
      _orgMobileController.text = orgData['contactDetails'];
      _orgDescriptionController.text = orgData['intro'];
      _orgBarangayController.text = orgData['barangay'];
      _orgMajorClassificationController.text = orgData['majorClassification'];
      _orgSubclassificationController.text = orgData['subClassification'];
      _orgEmailAddressController.text = orgData['email'];
      _orgInitialMemberCountController.text =
          orgData['initialMemberCount'].toString();
      dateEstablished = (orgData['dateEstablished'] as Timestamp).toDate();
      _orgMunicipalityController.text = orgData['municipality'];

      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting org head data: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editOrgHead() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      // Initialize Org Head
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.orgHeadID)
          .update({
        'userType': 'ORG HEAD',
        'lastName': _familyNameController.text,
        'firstName': _givenNameController.text,
        'middleName': _middleNameController.text,
        'contactNumber': _contactNumberController.text,
        'orgHeadEmail': _headEmailAddressController.text,
        'adviserLastName': _adviserLastNameController.text,
        'adviserFirstName': _adviserGivenNameController.text,
        'adviserMiddleName': _adviserMiddleNameController.text,
        'adviserContactNumber': _adviserContactNumberController.text,
        'adviserEmail': _adviseremailAddressController.text,
      });

      //  Initialize Org
      await FirebaseFirestore.instance
          .collection('orgs')
          .doc(widget.orgID)
          .update({
        'name': _orgNameController.text.trim(),
        'telephone': _orgTelephoneController.text.trim(),
        'contactDetails': _orgMobileController.text.trim(),
        'intro': _orgDescriptionController.text.trim(),
        'barangay': _orgBarangayController.text,
        'majorClassification': _orgMajorClassificationController.text,
        'subClassification': _orgSubclassificationController.text,
        'email': _orgEmailAddressController.text,
        'initialMemberCount':
            double.tryParse(_orgInitialMemberCountController.text) ?? 0,
        'dateEstablished': dateEstablished!,
        'municipality': _orgEmailAddressController.text
      });

      //  Redirect to the login screen when all of this is done.
      setState(() {
        _isLoading = false;
      });
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully editted org head account')));
      goRouter.go('/orgHeads');
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error editing org head account: $error')));
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
          leftNavigator(context, 2),
          bodyWidgetWhiteBG(
              context,
              stackedLoadingContainer(
                  context,
                  _isLoading,
                  SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: _currentRegisterStateBox(),
                      ))))
        ],
      ),
    );
  }

  Widget _currentRegisterStateBox() {
    if (currentRegisterState == RegisterStates.MEMBERSHIP) {
      return addOrgHeadBoxContainer(context,
          child: SingleChildScrollView(
              child: Column(children: [
            registerHeader(),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_orgHeadFields(), _adviserFields()]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              registerActionButton('BACK', handlePreviousButton),
              registerActionButton('NEXT', handleNextButton)
            ])
          ])));
    } else {
      return addOrgHeadBoxContainer(context,
          child: SingleChildScrollView(
              child: Column(children: [
            registerHeader(),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_orgDataLeftColumn(), _orgDataRightColumn()]),
            _orgDescription(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              registerActionButton('PREVIOUS', handlePreviousButton),
              registerActionButton('SUBMIT', handleNextButton)
            ])
          ])));
    }
  }

  //  MEMBERSHIP WIDGETS
  //============================================================================
  Widget _orgHeadFields() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              AutoSizeText(
                'Head of Organization',
                style: blackBoldStyle(),
              )
            ]),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Column(
              children: [
                _familyName(),
                _givenName(),
                _middleName(),
                _contactNumber(),
                _headEmailAddress()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _familyName() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Family Name', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
            text: '',
            controller: _familyNameController,
            textInputType: TextInputType.text,
            displayPrefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget _givenName() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Given Name', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
            text: '',
            controller: _givenNameController,
            textInputType: TextInputType.text,
            displayPrefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget _middleName() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Middle Name', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
            text: '',
            controller: _middleNameController,
            textInputType: TextInputType.text,
            displayPrefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget _contactNumber() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Contact Number', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
            text: '',
            controller: _contactNumberController,
            textInputType: TextInputType.number,
            displayPrefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget _headEmailAddress() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Email Address', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
            text: '',
            controller: _headEmailAddressController,
            textInputType: TextInputType.emailAddress,
            displayPrefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget _adviserFields() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              AutoSizeText('Adviser of the Organization',
                  style: blackBoldStyle())
            ]),
          ),
          _adviserFamilyName(),
          _adviserGivenName(),
          _adviserMiddleName(),
          _adviserContactNumber(),
          _adviserEmailAddress()
        ],
      ),
    );
  }

  Widget _adviserFamilyName() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Family Name', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
            text: '',
            controller: _adviserLastNameController,
            textInputType: TextInputType.text,
            displayPrefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget _adviserGivenName() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Given Name', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
            text: '',
            controller: _adviserGivenNameController,
            textInputType: TextInputType.text,
            displayPrefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget _adviserMiddleName() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Middle Name', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
            text: '',
            controller: _adviserMiddleNameController,
            textInputType: TextInputType.text,
            displayPrefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget _adviserContactNumber() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Contact Number', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
            text: '',
            controller: _adviserContactNumberController,
            textInputType: TextInputType.number,
            displayPrefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget _adviserEmailAddress() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Email Address', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
            text: '',
            controller: _adviseremailAddressController,
            textInputType: TextInputType.emailAddress,
            displayPrefixIcon: null,
          ),
        ],
      ),
    );
  }

  //  ORGANIZATION WIDGETS
  //============================================================================
  Widget _orgDataLeftColumn() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.2,
        child: Column(children: [
          Column(children: [
            _orgName(),
            Row(children: [_orgTelephone(), _orgMobile()]),
            _orgIsland(),
            _orgProvince(),
            _orgBarangay(),
            _orgMajorClassification()
          ])
        ]));
  }

  Widget _orgName() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Name of Organization',
                style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
            text: '',
            controller: _orgNameController,
            textInputType: TextInputType.text,
            displayPrefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget _orgTelephone() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(children: [
              AutoSizeText('Telephone No.', style: blackBoldStyle(size: 10))
            ]),
            YouthConnectTextField(
              text: '',
              controller: _orgTelephoneController,
              textInputType: TextInputType.number,
              displayPrefixIcon: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _orgMobile() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(children: [
              AutoSizeText('Mobile No.', style: blackBoldStyle(size: 10))
            ]),
            YouthConnectTextField(
              text: '',
              controller: _orgMobileController,
              textInputType: TextInputType.number,
              displayPrefixIcon: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _orgIsland() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(children: [
              AutoSizeText('Island', style: blackBoldStyle(size: 10))
            ]),
            YouthConnectTextField(
                text: 'LUZON',
                controller: _orgIslandController,
                textInputType: TextInputType.text,
                displayPrefixIcon: null,
                enabled: false),
          ],
        ));
  }

  Widget _orgProvince() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(children: [
              AutoSizeText('Province', style: blackBoldStyle(size: 10))
            ]),
            YouthConnectTextField(
              text: 'LAGUNA',
              controller: _orgProvinceController,
              textInputType: TextInputType.text,
              displayPrefixIcon: null,
              enabled: false,
            ),
          ],
        ));
  }

  Widget _orgBarangay() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Barangay', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
              text: '',
              controller: _orgBarangayController,
              textInputType: TextInputType.text,
              displayPrefixIcon: null),
        ],
      ),
    );
  }

  Widget _orgMajorClassification() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Major Classification',
                style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
              text: '',
              controller: _orgMajorClassificationController,
              textInputType: TextInputType.text,
              displayPrefixIcon: null),
        ],
      ),
    );
  }

  Widget _orgDataRightColumn() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.2,
      child: Column(
        children: [
          _orgEmail(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_orgMemberCount(), _orgDateEstablished()],
          ),
          _orgRegion(),
          _orgMunicipality(),
          Gap(80),
          _orgSubclassification()
        ],
      ),
    );
  }

  Widget _orgEmail() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Email Address', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
            text: '',
            controller: _orgEmailAddressController,
            textInputType: TextInputType.emailAddress,
            displayPrefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget _orgMemberCount() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(children: [
              AutoSizeText('No. of Members', style: blackBoldStyle(size: 10))
            ]),
            YouthConnectTextField(
              text: '',
              controller: _orgInitialMemberCountController,
              textInputType: TextInputType.number,
              displayPrefixIcon: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _orgDateEstablished() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(children: [
              AutoSizeText('Date Established', style: blackBoldStyle(size: 10))
            ]),
            Container(
              width: MediaQuery.of(context).size.width * 0.1,
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 0.5),
                  borderRadius: BorderRadius.circular(10)),
              child: TextButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent),
                  onPressed: () => _selectDate(context),
                  child: Text(
                      dateEstablished != null
                          ? DateFormat('MMM dd, yyyy').format(dateEstablished!)
                          : '',
                      style: TextStyle(color: Colors.black))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orgRegion() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(children: [
              AutoSizeText('Region', style: blackBoldStyle(size: 10))
            ]),
            YouthConnectTextField(
              text: 'Region IV-A',
              controller: _orgRegionController,
              textInputType: TextInputType.text,
              displayPrefixIcon: null,
              enabled: false,
            ),
          ],
        ));
  }

  Widget _orgMunicipality() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Municipality', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
            text: '',
            controller: _orgMunicipalityController,
            textInputType: TextInputType.text,
            displayPrefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget _orgSubclassification() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Sub Classification', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
              text: '',
              controller: _orgSubclassificationController,
              textInputType: TextInputType.text,
              displayPrefixIcon: null),
        ],
      ),
    );
  }

  Widget _orgDescription() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            AutoSizeText('Org Description', style: blackBoldStyle(size: 10))
          ]),
          YouthConnectTextField(
              text: '',
              controller: _orgDescriptionController,
              textInputType: TextInputType.multiline,
              displayPrefixIcon: null),
        ],
      ),
    );
  }
}
