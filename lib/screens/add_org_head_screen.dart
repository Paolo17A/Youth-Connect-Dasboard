import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/youth_connect_textfield_widget.dart';

class AddOrgHeadScreen extends StatefulWidget {
  const AddOrgHeadScreen({super.key});

  @override
  State<AddOrgHeadScreen> createState() => _AddOrgHeadScreenState();
}

enum RegisterStates { SIGNUP, MEMBERSHIP, ORGANIZATION, FORMS }

class _AddOrgHeadScreenState extends State<AddOrgHeadScreen> {
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasLoggedInUser()) {
        GoRouter.of(context).go('/login');
        return;
      }
    });
  }

  bool _isLoading = false;
  RegisterStates currentRegisterState = RegisterStates.SIGNUP;

  //  Sign Up Text Fields
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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

  //  Form Upload Fields
  Uint8List? _formRegistrationSelectedFileBytes;
  String? _formRegistrationSelectedFileName;
  String? _formRegistrationSelectedFileExtension;
  Uint8List? _formMembersSelectedFileBytes;
  String? _formMembersSelectedFileName;
  String? _formMembersSelectedFileExtension;
  Uint8List? _formDirectorySelectedFileBytes;
  String? _formDirectorySelectedFileName;
  String? _formDirectorySelectedFileExtension;
  Uint8List? _formMissionVisionSelectedFileBytes;
  String? _formMissionVisionSelectedFileName;
  String? _formMissionVisionSelectedFileExtension;

  void handlePreviousButton() {
    setState(() {
      switch (currentRegisterState) {
        case RegisterStates.SIGNUP:
          GoRouter.of(context).go('/orgHeads');
          break;
        case RegisterStates.MEMBERSHIP:
          currentRegisterState = RegisterStates.SIGNUP;
          break;
        case RegisterStates.ORGANIZATION:
          currentRegisterState = RegisterStates.MEMBERSHIP;
          break;
        case RegisterStates.FORMS:
          currentRegisterState = RegisterStates.ORGANIZATION;
        default:
          break;
      }
    });
  }

  void handleNextButton() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      switch (currentRegisterState) {
        case RegisterStates.SIGNUP:
          if (_emailController.text.isEmpty ||
              _usernameController.text.isEmpty ||
              _passwordController.text.isEmpty ||
              _confirmPasswordController.text.isEmpty) {
            scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Please fill up all fields.')));
            return;
          } else if (!isAlphanumeric(_usernameController.text)) {
            scaffoldMessenger.showSnackBar(const SnackBar(
                content: Text(
                    'The username most only consist of letters and numbers.')));
            return;
          } else if (!_emailController.text.contains('@') ||
              !_emailController.text.contains('.com')) {
            scaffoldMessenger.showSnackBar(const SnackBar(
                content: Text('Please enter a valid email address.')));
            return;
          } else if (_passwordController.text !=
              _confirmPasswordController.text) {
            scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Passwords do not match.')));
            return;
          } else if (_passwordController.text.length < 6) {
            scaffoldMessenger.showSnackBar(const SnackBar(
                content:
                    Text('Password must be at least six characters long')));
            return;
          }
          currentRegisterState = RegisterStates.MEMBERSHIP;
          break;
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
          currentRegisterState = RegisterStates.FORMS;
          break;
        default:
          if (_formDirectorySelectedFileBytes == null ||
              _formMembersSelectedFileBytes == null ||
              _formMissionVisionSelectedFileBytes == null ||
              _formRegistrationSelectedFileBytes == null) {
            scaffoldMessenger.showSnackBar(const SnackBar(
                content: Text('Please upload all the required forms.')));
            return;
          }
          _registerNewOrgHead();
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

  Future pickFormRegistration() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        if (result.files.first.extension != 'pdf' &&
            result.files.first.extension != 'doc' &&
            result.files.first.extension != 'docx') {
          scaffoldMessenger.showSnackBar(const SnackBar(
              content: Text('Please select a .pdf, .doc, or .docx file.')));
          return;
        }
        setState(() {
          _formRegistrationSelectedFileBytes = result.files.first.bytes;
          _formRegistrationSelectedFileName = result.files.first.name;
          _formRegistrationSelectedFileExtension = result.files.first.extension;
        });
      } else {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Selected File is null.')));
      }
    } catch (error) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Error picking file: $error')));
    }
  }

  Future pickFormMembers() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        if (result.files.first.extension != 'pdf' &&
            result.files.first.extension != 'doc' &&
            result.files.first.extension != 'docx') {
          scaffoldMessenger.showSnackBar(const SnackBar(
              content: Text('Please select a .pdf, .doc, or .docx file.')));
          return;
        }
        setState(() {
          _formMembersSelectedFileBytes = result.files.first.bytes;
          _formMembersSelectedFileName = result.files.first.name;
          _formMembersSelectedFileExtension = result.files.first.extension;
        });
      } else {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Selected File is null.')));
      }
    } catch (error) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Error picking file: $error')));
    }
  }

  Future pickFormDirectory() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        if (result.files.first.extension != 'pdf' &&
            result.files.first.extension != 'doc' &&
            result.files.first.extension != 'docx') {
          scaffoldMessenger.showSnackBar(const SnackBar(
              content: Text('Please select a .pdf, .doc, or .docx file.')));
          return;
        }
        setState(() {
          _formDirectorySelectedFileBytes = result.files.first.bytes;
          _formDirectorySelectedFileName = result.files.first.name;
          _formDirectorySelectedFileExtension = result.files.first.extension;
        });
      } else {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Selected File is null.')));
      }
    } catch (error) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Error picking file: $error')));
    }
  }

  Future pickFormMissionVision() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        if (result.files.first.extension != 'pdf' &&
            result.files.first.extension != 'doc' &&
            result.files.first.extension != 'docx') {
          scaffoldMessenger.showSnackBar(const SnackBar(
              content: Text('Please select a .pdf, .doc, or .docx file.')));
          return;
        }
        setState(() {
          _formMissionVisionSelectedFileBytes = result.files.first.bytes;
          _formMissionVisionSelectedFileName = result.files.first.name;
          _formMissionVisionSelectedFileExtension =
              result.files.first.extension;
        });
      } else {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Selected File is null.')));
      }
    } catch (error) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Error picking file: $error')));
    }
  }

  void _registerNewOrgHead() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    //  Guard conditionals

    try {
      setState(() {
        _isLoading = true;
      });
      // Check if the desired username already exists in Firestore
      final usernameExists = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: _usernameController.text)
          .get();

      if (usernameExists.docs.isNotEmpty) {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Username is already taken.')));
        setState(() {
          _isLoading = false;
          currentRegisterState = RegisterStates.SIGNUP;
        });
        return;
      }

      final currentAdminUser = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final currentAdminData = currentAdminUser.data() as Map<dynamic, dynamic>;
      final adminEmail = currentAdminData['email'];
      final adminPassword = currentAdminData['password'];

      await FirebaseAuth.instance.signOut();

      //  Proceed with registration of user.
      final newUser =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Initialize Org Head
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'userType': 'ORG HEAD',
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
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
        'renewalHistory': [],
        'registrationForm': '',
        'listOfMembersForm': '',
        'directoryForm': '',
        'missionVision': ''
      });

      //  Initialize Org
      String orgID = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance.collection('orgs').doc(orgID).set({
        'name': _orgNameController.text.trim(),
        'nature': '',
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
        'municipality': _orgEmailAddressController.text,
        'socMed': '',
        'logoURL': '',
        'coverURL': '',
        'members': [],
        'isActive': true,
        'head': newUser.user!.uid,
        'isAccredited': true,
        'accreditationStatus': 'APPROVED',
        'dateApproved': DateTime.now()
      });

      //  Registration
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('orgs')
          .child(orgID)
          .child('registrationForm.${_formRegistrationSelectedFileExtension!}');
      UploadTask uploadTask =
          storageRef.putData(_formRegistrationSelectedFileBytes!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String registrationFormDownloadURL =
          await taskSnapshot.ref.getDownloadURL();

      //  List of Members
      storageRef = FirebaseStorage.instance
          .ref()
          .child('orgs')
          .child(orgID)
          .child('listOfMembers.${_formMembersSelectedFileExtension!}');
      uploadTask = storageRef.putData(_formRegistrationSelectedFileBytes!);
      taskSnapshot = await uploadTask.whenComplete(() {});
      String listOfMembersFormDownloadURL =
          await taskSnapshot.ref.getDownloadURL();

      //  Directory
      storageRef = FirebaseStorage.instance
          .ref()
          .child('orgs')
          .child(orgID)
          .child('orgDirectory.${_formDirectorySelectedFileExtension}');

      uploadTask = storageRef.putData(_formRegistrationSelectedFileBytes!);
      taskSnapshot = await uploadTask.whenComplete(() {});
      String directoryFormDownloadURL = await taskSnapshot.ref.getDownloadURL();

      //  Mission and Vision
      storageRef = FirebaseStorage.instance
          .ref()
          .child('orgs')
          .child(orgID)
          .child(
              'missionAndVision.${_formMissionVisionSelectedFileExtension!}');

      uploadTask = storageRef.putData(_formRegistrationSelectedFileBytes!);
      taskSnapshot = await uploadTask.whenComplete(() {});
      String missionAndVisionFormDownloadURL =
          await taskSnapshot.ref.getDownloadURL();

      //  Update the newly created user with the new download links
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.user!.uid)
          .update({
        'registrationForm': registrationFormDownloadURL,
        'listOfMembersForm': listOfMembersFormDownloadURL,
        'directoryForm': directoryFormDownloadURL,
        'missionVision': missionAndVisionFormDownloadURL,
        'organization': orgID,
      });

      await FirebaseAuth.instance.signOut();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: adminEmail, password: adminPassword);

      //  Redirect to the login screen when all of this is done.
      setState(() {
        _isLoading = false;
      });
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully created new account')));
      goRouter.go('/orgHeads');
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error registering new user: $error')));
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
    if (currentRegisterState == RegisterStates.SIGNUP) {
      return addOrgHeadBoxContainer(
        context,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _signUpHeader(),
              _username(),
              _emailAddress(),
              _password(),
              _confirmPassword(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  registerActionButton('BACK', handlePreviousButton),
                  registerActionButton('NEXT', handleNextButton),
                ],
              )
            ],
          ),
        ),
      );
    } else if (currentRegisterState == RegisterStates.MEMBERSHIP) {
      return addOrgHeadBoxContainer(context,
          child: SingleChildScrollView(
              child: Column(children: [
            registerHeader(),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_orgHeadFields(), _adviserFields()]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              registerActionButton('PREVIOUS', handlePreviousButton),
              registerActionButton('NEXT', handleNextButton)
            ])
          ])));
    } else if (currentRegisterState == RegisterStates.ORGANIZATION) {
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
                children: [
                  Column(
                    children: [_formRegistration(), _formMembersList()],
                  ),
                  Column(
                    children: [_formDirectory(), _formMissionVision()],
                  )
                ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              registerActionButton('PREVIOUS', handlePreviousButton),
              registerActionButton('SUBMIT', handleNextButton)
            ])
          ])));
    }
  }

  //  SIGNUP WIDGETS
  //============================================================================
  Widget _signUpHeader() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [
          Text('Sign Up',
              style: GoogleFonts.poppins(textStyle: blackBoldStyle(size: 30)))
        ]),
        Divider(thickness: 2)
      ]),
    );
  }

  Widget _username() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: YouthConnectTextField(
        text: 'Username',
        controller: _usernameController,
        textInputType: TextInputType.text,
        displayPrefixIcon: const Icon(Icons.person_2),
      ),
    );
  }

  Widget _emailAddress() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: YouthConnectTextField(
        text: 'Email Address',
        controller: _emailController,
        textInputType: TextInputType.emailAddress,
        displayPrefixIcon: const Icon(Icons.email),
      ),
    );
  }

  Widget _password() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: YouthConnectTextField(
        text: 'Password',
        controller: _passwordController,
        textInputType: TextInputType.visiblePassword,
        displayPrefixIcon: const Icon(Icons.lock),
      ),
    );
  }

  Widget _confirmPassword() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: YouthConnectTextField(
        text: 'Confirm Password',
        controller: _confirmPasswordController,
        textInputType: TextInputType.visiblePassword,
        displayPrefixIcon: const Icon(Icons.lock),
      ),
    );
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

  //  FORM WIDGETS
  //============================================================================
  Widget _formRegistration() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            AutoSizeText('Registration Form', style: blackBoldStyle(size: 15))
          ]),
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            height: 50,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.5),
                borderRadius: BorderRadius.circular(10)),
            child: TextButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent),
                onPressed: () async => pickFormRegistration(),
                child: Text(
                    _formRegistrationSelectedFileBytes != null
                        ? _formRegistrationSelectedFileName!
                        : 'Click Here to Upload',
                    style: TextStyle(color: Colors.black))),
          ),
        ],
      ),
    );
  }

  Widget _formMembersList() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            AutoSizeText('List of Members', style: blackBoldStyle(size: 15))
          ]),
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            height: 50,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.5),
                borderRadius: BorderRadius.circular(10)),
            child: TextButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent),
                onPressed: () async => pickFormMembers(),
                child: Text(
                    _formMembersSelectedFileBytes != null
                        ? _formMembersSelectedFileName!
                        : 'Click Here to Upload',
                    style: TextStyle(color: Colors.black))),
          ),
        ],
      ),
    );
  }

  Widget _formDirectory() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            AutoSizeText('Directory of Officers and Advisers',
                style: blackBoldStyle(size: 15))
          ]),
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            height: 50,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.5),
                borderRadius: BorderRadius.circular(10)),
            child: TextButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent),
                onPressed: () async => pickFormDirectory(),
                child: Text(
                    _formDirectorySelectedFileBytes != null
                        ? _formDirectorySelectedFileName!
                        : 'Click Here to Upload',
                    style: TextStyle(color: Colors.black))),
          ),
        ],
      ),
    );
  }

  Widget _formMissionVision() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            AutoSizeText('Mission and Vision', style: blackBoldStyle(size: 15))
          ]),
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            height: 50,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.5),
                borderRadius: BorderRadius.circular(10)),
            child: TextButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent),
                onPressed: () async => pickFormMissionVision(),
                child: Text(
                    _formMissionVisionSelectedFileBytes != null
                        ? _formMissionVisionSelectedFileName!
                        : 'Click Here to Upload',
                    style: TextStyle(color: Colors.black))),
          ),
        ],
      ),
    );
  }
}
