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

      //  reset the password in firebase in case admin forgot their password and reset it using an email link.
      if (currentUserData.data()!['password'] != _passwordController.text) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'password': _passwordController.text});
      }

      //  Check if the account has a userType parameter and create it if it doesn't.
      if (!currentUserData.data()!.containsKey('userType')) {
        await FirebaseFirestore.instance
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

      if (currentUserData.data()!['userType'] == 'ADMIN') {
        goRouter.go('/home');
      } else if (currentUserData.data()!['userType'] == 'ORG HEAD') {
        goRouter.go('/orgHome');
      }
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
                            _loginHeader(),
                            _emailAddress(),
                            _password(),
                            _logInButton(),
                            _textButtons(),
                            // _organizationOption()
                          ],
                        ),
                      ),
                    ),
                  ),
                ))));
  }

  Widget _loginHeader() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('LOG IN',
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

  Widget _logInButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: submitButton(context,
          text: 'Log In',
          submitFunction: loginUser,
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.06),
    );
  }

  Widget _textButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        TextButton(
            onPressed: () {},
            child: Text('Forgot Password?',
                style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w400)))),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text('New Here? ',
                style: GoogleFonts.poppins(
                    textStyle:
                        const TextStyle(fontSize: 16, color: Colors.black))),
            TextButton(
                onPressed: () => GoRouter.of(context).go('/register'),
                child: Text('Sign Up',
                    style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color.fromARGB(255, 34, 52, 189)))))
          ],
        )
      ]),
    );
  }
}
