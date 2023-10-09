import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/custom_textfield_widget.dart';
import '../widgets/submit_button_widget.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    final scaffoldState = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    FocusScope.of(context).unfocus();
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      scaffoldState.showSnackBar(
          const SnackBar(content: Text('Please fill up all the fields')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      //  Attempt log-in with username
      if (!_emailController.text.contains('@') &&
          !_emailController.text.contains('.com')) {
        final allUsers = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isNull: false)
            .where('username', isEqualTo: _emailController.text)
            .get();

        //  We found a user. We will log in using that email address.
        if (allUsers.docs.isNotEmpty) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: allUsers.docs.first.data()['email'],
              password: _passwordController.text);
        }
        //  Username does not exist.
        else {
          scaffoldState.showSnackBar(SnackBar(
              content: Text(
                  'No account with username \'${_emailController.text}\' found.')));
          setState(() {
            _isLoading = false;
            _emailController.clear();
            _passwordController.clear();
          });
          return;
        }
      }
      //  Sign in using the email and password
      else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);
      }

      //  Get the currentUserData
      final currentUserData = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      //  Check if the account has a userType parameter and create it if it doesn't.
      if (!currentUserData.data()!.containsKey('userType')) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'userType': 'CLIENT'});

        //  If the current user is an admin, display a mesaage.
      } else if (currentUserData.data()!['userType'] == 'CLIENT') {
        scaffoldState.showSnackBar(
            const SnackBar(content: Text('Only admins may access this app')));
        await FirebaseAuth.instance.signOut();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      goRouter.go('/home');
    } catch (error) {
      setState(() {
        _isLoading = false;
        _emailController.clear();
        _passwordController.clear();
      });
      scaffoldState.showSnackBar(SnackBar(content: Text(error.toString())));
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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 130),
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
                          Text('LOG IN',
                              style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30))),
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
                          Row(children: [
                            TextButton(
                                onPressed: () {},
                                child: Text('Forgot Password?',
                                    style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            color: Color.fromARGB(
                                                255, 34, 52, 189),
                                            fontWeight: FontWeight.bold))))
                          ]),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.08),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: submitButton(
                                context: context,
                                submitFunction: loginUser,
                                width: MediaQuery.of(context).size.width * 0.15,
                                height:
                                    MediaQuery.of(context).size.height * 0.06),
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text('Don\'t have an account? ',
                                  style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                          fontSize: 16, color: Colors.black))),
                              TextButton(
                                  onPressed: () {
                                    GoRouter.of(context).go('/register');
                                  },
                                  child: Text('Register Here',
                                      style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontSize: 14,
                                              color: Color.fromARGB(
                                                  255, 34, 52, 189)))))
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
