import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_text_widgets.dart';

import '../widgets/custom_button_widgets.dart';
import '../widgets/youth_connect_textfield_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  void _sendResetEmail() async {
    if (_emailController.text.isEmpty ||
        !_emailController.text.contains('@') ||
        !_emailController.text.contains('.com')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please provide a valid email address.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      final allUsers = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();

      if (allUsers.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'No user with email address \'${_emailController.text.trim()}\' found.')));
        setState(() {
          _isLoading = false;
          _emailController.clear();
        });
        return;
      }
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sucessfully sent reset password email.')));
      GoRouter.of(context).go('/login');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending reset email: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: loginAppBar(context),
        body: loginBackgroundContainer(context,
            child: stackedLoadingContainer(
                context,
                _isLoading,
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: loginBoxContainer(
                      context,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _resetHeader(),
                            _emailAddress(),
                            _logInButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ))));
  }

  Widget _resetHeader() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('RESET PASSWORD',
          style: GoogleFonts.poppins(textStyle: blackBoldStyle(size: 30))),
      Divider(thickness: 2)
    ]);
  }

  Widget _emailAddress() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: YouthConnectTextField(
        text: 'Email Address',
        controller: _emailController,
        textInputType: TextInputType.emailAddress,
        displayPrefixIcon: const Icon(Icons.email),
      ),
    );
  }

  Widget _logInButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: submitButton(context,
          text: 'Log In',
          submitFunction: _sendResetEmail,
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.06),
    );
  }
}
