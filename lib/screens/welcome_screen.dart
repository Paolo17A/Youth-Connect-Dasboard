import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(15),
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ywda_admin_logo.png',
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              const SizedBox(height: 60),
              Text('Welcome to Youth Connect',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 19))),
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                      'A dynamic platform designed to empower and unite young minds. Youth Connect is your go-to hub for growth, inspiration, and colalboration. Join us today and embark on a journey of personal development, networking, and youth-led innovation.',
                      textAlign: TextAlign.justify,
                      style: GoogleFonts.poppins(
                          textStyle:
                              const TextStyle(fontSize: 13, height: 1.5)))),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.15,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 34, 52, 189),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      GoRouter.of(context).go('/register');
                    },
                    child: const Text('GET STARTED',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                        onPressed: () {
                          GoRouter.of(context).go('/login');
                        },
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
