import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/youth_connect_textfield_widget.dart';

class EditYouthInformationScreen extends StatefulWidget {
  final String returnPoint;
  final String youthID;
  const EditYouthInformationScreen(
      {super.key, required this.returnPoint, required this.youthID});

  @override
  State<EditYouthInformationScreen> createState() =>
      _EditYouthInformationScreenState();
}

class _EditYouthInformationScreenState
    extends State<EditYouthInformationScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _residingCity = '';
  //DateTime? birthday;
  //int age = 0;
  String _gender = '';
  List<String> fixedGenders = [
    'WOMAN',
    'MAN',
    'NON-BINARY',
    'TRANSGENDER',
    'INTERSEX',
    'PREFER NOT TO SAY'
  ];
  String _civilStatus = '';
  final _schoolController = TextEditingController();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasLoggedInUser()) {
        GoRouter.of(context).goNamed(GoRoutes.login);
        return;
      }
      if (!_isInitialized) getYouthInformation();
    });
  }

  void getYouthInformation() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final youth = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.youthID)
          .get();
      final youthData = youth.data() as Map<dynamic, dynamic>;
      _firstNameController.text = youthData['firstName'];
      _middleNameController.text = youthData['middleName'];
      _lastNameController.text = youthData['lastName'];
      _residingCity = youthData['city'];
      //birthday = (youthData['birthday'] as Timestamp).toDate();
      //age = _calculateAge(birthday!);
      _gender = youthData['gender'];
      _civilStatus = youthData['civilStatus'];
      _schoolController.text = youthData['school'];

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting youth information: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  /*Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        birthday = picked;
        age = _calculateAge(birthday!);
      });
    }
  }*/

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  void updateThisYouth() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (_firstNameController.text.isEmpty ||
        _middleNameController.text.isEmpty ||
        _lastNameController.text.isEmpty) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Please fill up all fields')));
      return;
    } /*else if (age < 15 || age > 30) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Your age must be between 15-30 years old.')));
      return;
    }*/

    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.youthID)
          .update({
        'firstName': _firstNameController.text,
        'middleName': _middleNameController.text,
        'lastName': _lastNameController.text,
        'city': _residingCity,
        //'birthday': birthday,
        'gender': _gender,
        'civilStatus': _civilStatus,
        'school': _schoolController.text.trim()
      });

      setState(() {
        _isLoading = false;
      });
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully edited profile!')));
      String returnPath = '';
      if (widget.returnPoint == '1.1') {
        returnPath = '/ageReport';
      } else if (widget.returnPoint == '1.2') {
        returnPath = '/genderReport';
      } else {
        returnPath = '/users';
      }
      widget.returnPoint == '1'
          ? GoRouter.of(context).goNamed('youthInformation',
              pathParameters: {'category': 'NO FILTER'})
          : GoRouter.of(context).go(returnPath);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error updating user profile: $error')));
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
          leftNavigator(context,
              widget.returnPoint == '1' ? 1 : double.parse(widget.returnPoint)),
          bodyWidgetWhiteBG(
              context,
              stackedLoadingContainer(
                  context,
                  _isLoading,
                  SingleChildScrollView(
                      child: Column(
                    children: [
                      _backButton(),
                      horizontalPadding5Percent(
                          context,
                          Column(
                            children: [
                              _editYouthHeaderWidget(),
                              _firstNameWidget(),
                              _middleNameWidget(),
                              _lastNameWidget(),
                              _residingCityWidget(),
                              _genderWidget(),
                              _civilStatusWidgets(),
                              _schoolWidget(),
                              Gap(30),
                              _submitButtonWidget()
                            ],
                          ))
                    ],
                  ))))
        ],
      ),
    );
  }

  //  COMPONENT WIDGETS
  //============================================================================
  Widget _backButton() {
    String returnPath = '';
    if (widget.returnPoint == '1.1') {
      returnPath = '/ageReport';
    } else if (widget.returnPoint == '1.2') {
      returnPath = '/genderReport';
    } else {
      returnPath = '/users';
    }
    return Row(children: [
      backToViewScreenButton(context,
          onPress: () => widget.returnPoint == '1'
              ? GoRouter.of(context).goNamed('youthInformation',
                  pathParameters: {'category': 'NO FILTER'})
              : GoRouter.of(context).go(returnPath))
    ]);
  }

  Widget _editYouthHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: AutoSizeText(
        'EDIT YOUTH INFORMATION',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(textStyle: blackBoldStyle(size: 38)),
      ),
    );
  }

  Widget _firstNameWidget() {
    return Column(children: [
      vertical10horizontal4(Row(children: [
        AutoSizeText('First Name', style: interSize19()),
        AutoSizeText('*', style: interSize19(textColor: Colors.red))
      ])),
      YouthConnectTextField(
          text: 'First Name',
          controller: _firstNameController,
          textInputType: TextInputType.text,
          displayPrefixIcon: null),
      const SizedBox(height: 20)
    ]);
  }

  Widget _middleNameWidget() {
    return Column(children: [
      vertical10horizontal4(Row(children: [
        AutoSizeText('Middle Name', style: interSize19()),
        AutoSizeText('*', style: interSize19(textColor: Colors.red))
      ])),
      YouthConnectTextField(
          text: 'Middle Name',
          controller: _middleNameController,
          textInputType: TextInputType.text,
          displayPrefixIcon: null),
      const SizedBox(height: 20)
    ]);
  }

  Widget _lastNameWidget() {
    return Column(children: [
      vertical10horizontal4(Row(children: [
        AutoSizeText('Last Name', style: interSize19()),
        AutoSizeText('*', style: interSize19(textColor: Colors.red))
      ])),
      YouthConnectTextField(
          text: 'Last Name',
          controller: _lastNameController,
          textInputType: TextInputType.text,
          displayPrefixIcon: null),
      const SizedBox(height: 20)
    ]);
  }

  Widget _residingCityWidget() {
    return Column(children: [
      Row(children: [
        AutoSizeText('Residing City', style: interSize19()),
        AutoSizeText('*', style: interSize19(textColor: Colors.red))
      ]),
      dropdownWidget(_residingCity, (selected) {
        setState(() {
          if (selected != null) {
            _residingCity = selected;
          }
        });
      }, [
        'Alaminos',
        'Bay',
        'Biñan',
        'Botocan',
        'Cabuyao',
        'Calamba',
        'Camp Vicente Lim',
        'Canlubang',
        'Cavinti',
        'College Los Baños',
        'Famy',
        'Kalayaan',
        'Liliw',
        'Los Baños',
        'Luisiana',
        'Lumban',
        'Mabitac',
        'Magdalena',
        'Majayjay',
        'Nagcarlan',
        'Paete',
        'Pagsanjan',
        'Pakil',
        'Pila',
        'Rizal',
        'San Pablo',
        'San Pedro',
        'Siniloan',
        'Sta. Cruz',
        'Sta. Maria',
        'Sta. Rosa',
        'Victoria'
      ], _residingCity, false),
    ]);
  }

  Widget _genderWidget() {
    return Column(children: [
      Row(children: [
        AutoSizeText('Gender', style: interSize19()),
        AutoSizeText('*', style: interSize19(textColor: Colors.red))
      ]),
      dropdownWidget(_gender, (selected) {
        setState(() {
          if (selected != null) {
            _residingCity = selected;
          }
        });
      }, fixedGenders, _gender, false),
    ]);
  }

  Widget _civilStatusWidgets() {
    return Padding(
        padding: EdgeInsets.all(8),
        child: Column(children: [
          Row(children: [
            Text('Civil Status', style: GoogleFonts.poppins()),
            AutoSizeText('*', style: interSize19(textColor: Colors.red))
          ]),
          dropdownWidget(_civilStatus, (selected) {
            setState(() {
              if (selected != null) {
                _civilStatus = selected;
              }
            });
          }, [
            'SINGLE',
            'MARRIED',
            'DIVORCED',
            'SINGLE-PARENTS',
            'WIDOWED',
            'SEPARATE'
          ], _civilStatus, false),
        ]));
  }

  Widget _schoolWidget() {
    return Column(children: [
      vertical10horizontal4(Row(children: [
        AutoSizeText('School', style: interSize19()),
        AutoSizeText('*', style: interSize19(textColor: Colors.red))
      ])),
      YouthConnectTextField(
          text: 'School',
          controller: _schoolController,
          textInputType: TextInputType.text,
          displayPrefixIcon: null),
      const SizedBox(height: 20)
    ]);
  }

  Widget _submitButtonWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => updateThisYouth(),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 88, 147, 201),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: AutoSizeText(
                'SUBMIT',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
