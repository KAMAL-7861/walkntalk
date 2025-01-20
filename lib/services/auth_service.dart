import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../presentation/auth/pages/login.dart';

void log(String message) {
  if (!kReleaseMode) {
    debugPrint(message);
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isSigningIn = false;

  static const String loggedInKey = 'isLoggedIn';

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    if (_isSigningIn) {
      log('Sign-in request already in progress.');
      return null;
    }

    try {
      _isSigningIn = true;
      log('Starting Google Sign-In process.');

      // Optionally sign out previous accounts
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        log('Google Sign-In canceled by user.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      log('Google Sign-In successful: ${userCredential.user?.email}');

      // Save login state in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(loggedInKey, true);

      return userCredential.user;
    } catch (e) {
      log('Error during Google Sign-In: $e');
      return null;
    } finally {
      _isSigningIn = false;
      log('Google Sign-In process completed.');
    }
  }

  // Sign out from Google
  Future<void> signoutWithGoogle(BuildContext context) async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();

      // Update SharedPreferences after signout
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false); // Mark the user as logged out

      // Navigate to the login page after logging out
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyLogin()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign-out: $e');
      }
    }
  }



  // Check if user is logged in using SharedPreferences
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loggedInKey) ?? false;
  }
}
