import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/widgets/custom_textfield_widget.dart';
import 'package:ywda_dashboard/widgets/submit_button_widget.dart';

import '../utils/string_checker_util.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  void _registerNewUser() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    //  Guard conditionals
    if (_emailController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all fields.')));
      return;
    } else if (!isAlphanumeric(_usernameController.text)) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content:
              Text('The username most only consist of letters and numbers.')));
      return;
    } else if (!_emailController.text.contains('@') ||
        !_emailController.text.contains('.com')) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please enter a valid email address.')));
      return;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Passwords do not match.')));
      return;
    }
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
          _usernameController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          _emailController.clear();
        });
        return;
      }

      //  Proceed with registration of user.
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Store the username and UID in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'userType': 'ADMIN',
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      });

      //  Send email verification link to user's email.
      //await userCredential.user!.sendEmailVerification();
      await FirebaseAuth.instance.signOut();

      //  Redirect to the login screen when all of this is done.
      setState(() {
        _isLoading = false;
      });
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully created new account')));
      goRouter.go('/login');
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
        body: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Stack(children: [
          Positioned(
            top: -15,
            right: -15,
            child: Image.asset('assets/images/icons/Design.png', scale: 2.75),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.45,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.deepPurple, Colors.blueAccent])),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Container(
                    color: const Color.fromARGB(255, 227, 236, 244),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 75,
                                child:
                                    Image.asset('assets/images/ywda_logo.png')),
                          ),
                          Text('SIGN UP',
                              style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30))),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: YouthConnectTextField(
                              text: 'Username',
                              controller: _usernameController,
                              textInputType: TextInputType.text,
                              displayPrefixIcon: const Icon(Icons.person_2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: YouthConnectTextField(
                              text: 'Email Address',
                              controller: _emailController,
                              textInputType: TextInputType.emailAddress,
                              displayPrefixIcon: const Icon(Icons.email),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: YouthConnectTextField(
                              text: 'Password',
                              controller: _passwordController,
                              textInputType: TextInputType.visiblePassword,
                              displayPrefixIcon: const Icon(Icons.lock),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: YouthConnectTextField(
                              text: 'Confirm Password',
                              controller: _confirmPasswordController,
                              textInputType: TextInputType.visiblePassword,
                              displayPrefixIcon: const Icon(Icons.lock),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: submitButton(
                                context: context,
                                submitFunction: _registerNewUser,
                                width: MediaQuery.of(context).size.width * 0.15,
                                height:
                                    MediaQuery.of(context).size.height * 0.06),
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text('Already have an account? ',
                                  style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                          fontSize: 16, color: Colors.black))),
                              TextButton(
                                  onPressed: () {
                                    GoRouter.of(context).go('/login');
                                  },
                                  child: Text('Log In',
                                      style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 34, 52, 189),
                                      ))))
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            )
        ]),
      ),
    ));
  }
}
