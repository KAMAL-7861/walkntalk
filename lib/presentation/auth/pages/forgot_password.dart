import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows the body to extend behind the AppBar
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent background
        elevation: 0, // Remove AppBar shadow
        iconTheme: const IconThemeData(color: Colors.white), // Set back button color to white
      ),
      body: Stack(
        children: [
          // Background Image or Color
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D47A1), // Dark blue
                  Color(0xFF512DA8), // Dark purple
                  Color(0xFF1A237E), // Indigo
                  Color(0xFFC2185B), // Dark pink
                ],
              ),
            ),
          ),
          // Semi-transparent overlay for readability (optional)
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress, // Optimized keyboard for email
                    decoration: InputDecoration(
                      hintText: 'Enter your Email',
                      hintStyle: const TextStyle(color: Colors.white70),
                      suffixIcon: const Icon(Icons.email, color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.pink),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.pink, width: 2.0), // Pink for focused state
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20,
                          vertical: 10),
                    ),
                    onPressed: () async {
                      final email = _emailController.text.trim();

                      // Check if email is valid before proceeding
                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter a valid email address")),
                        );
                        return;
                      }

                      try {
                        // Send password reset email
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Password reset email sent")),
                        );
                      } on FirebaseAuthException catch (ex) {
                        // Handle errors like invalid email
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${ex.message}")),
                        );
                      }
                    },
                    child: const Text(
                      'Reset Password',
                      style: TextStyle(color: Colors.white), // Set text
                      // color to black
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
