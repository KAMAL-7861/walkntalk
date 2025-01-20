import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../content/home_page_content.dart'; // Adjust import based on your structure
import 'login.dart'; // Adjust import based on your structure

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access FirebaseAuth instance
    final FirebaseAuth auth = FirebaseAuth.instance;

    return Scaffold(
      body: StreamBuilder<User?>(
        // Listen to authentication state changes
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          // Show a loading indicator while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if the user is authenticated
          if (snapshot.hasData && snapshot.data != null) {
            // User is authenticated, navigate to the HomeScreen
            return const HomeScreen(); // Replace with your home screen widget
          } else {
            // User is not authenticated, navigate to the Login screen
            return const MyLogin(); // Replace with your login screen widget
          }
        },
      ),
    );
  }
}
