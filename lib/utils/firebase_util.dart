import 'package:firebase_auth/firebase_auth.dart';

bool hasLoggedInUser() {
  return FirebaseAuth.instance.currentUser != null;
}
