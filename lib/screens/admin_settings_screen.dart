import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/youth_connect_textfield_widget.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../widgets/custom_text_widgets.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _isLoading = false;
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasLoggedInUser()) {
        GoRouter.of(context).goNamed(GoRoutes.login);
        return;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
  }

  Future changeAdminPassword() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmNewPasswordController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all the fields.')));
      return;
    }
    if (newPasswordController.text != confirmNewPasswordController.text) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Your new passwords do not match.')));
    }
    if (newPasswordController.text.length < 6) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Password must be at least 6 characters long.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      final admin = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final adminData = admin.data()!;

      if (currentPasswordController.text != adminData['password']) {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Your old password is incorrect')));
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: adminData['email'], password: adminData['password']);

      await FirebaseAuth.instance.currentUser!
          .updatePassword(newPasswordController.text);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'password': newPasswordController.text});

      setState(() {
        _isLoading = false;
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmNewPasswordController.clear();
      });
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully changed your password.')));
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error changing admin password: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context),
      body: Row(children: [
        leftNavigator(context, 0),
        bodyWidgetMercuryBG(
            context,
            stackedLoadingContainer(
                context,
                _isLoading,
                horizontalPadding5Percent(
                    context,
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.9,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3)),
                        child: horizontalPadding5Percent(
                          context,
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              verticalPadding5Percent(
                                  context,
                                  Text('ADMIN SETTINGS',
                                      style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 50,
                                              fontWeight: FontWeight.bold)))),
                              Row(children: [
                                AutoSizeText('*',
                                    style: interSize19(textColor: Colors.red))
                              ]),
                              YouthConnectTextField(
                                  text: 'Old Password',
                                  controller: currentPasswordController,
                                  textInputType: TextInputType.visiblePassword,
                                  displayPrefixIcon: const Icon(Icons.lock)),
                              Row(children: [
                                AutoSizeText('*',
                                    style: interSize19(textColor: Colors.red))
                              ]),
                              YouthConnectTextField(
                                  text: 'New Password',
                                  controller: newPasswordController,
                                  textInputType: TextInputType.visiblePassword,
                                  displayPrefixIcon: const Icon(Icons.lock)),
                              Row(children: [
                                AutoSizeText('*',
                                    style: interSize19(textColor: Colors.red))
                              ]),
                              YouthConnectTextField(
                                  text: 'Confirm New Password',
                                  controller: confirmNewPasswordController,
                                  textInputType: TextInputType.visiblePassword,
                                  displayPrefixIcon: const Icon(Icons.lock)),
                              verticalPadding5Percent(
                                  context,
                                  ElevatedButton(
                                      onPressed: changeAdminPassword,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 34, 52, 189),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Text('CHANGE PASSWORD',
                                            style: GoogleFonts.poppins(
                                                textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 28))),
                                      ))),
                              Gap(30),
                              ElevatedButton(
                                  onPressed: () {
                                    FirebaseAuth.instance
                                        .signOut()
                                        .then((value) {
                                      GoRouter.of(context)
                                          .goNamed(GoRoutes.login);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 34, 52, 189),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30))),
                                  child: Text('LOG OUT',
                                      style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20)))),
                            ],
                          ),
                        ),
                      ),
                    ))))
      ]),
    );
  }
}
