import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:walkntalk/presentation/auth/pages/home_page.dart';

class OtpScreen extends StatefulWidget {
  final String? verificationid;

  const OtpScreen({super.key, this.verificationid});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check if verificationid is null right away
    if (widget.verificationid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
      Navigator.pop(context); // Go back to the previous screen if verification ID is null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20), // Space at the top
            const Text(
              'Please enter the OTP sent to your mobile number:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30), // Space between elements

            // OTP Text Field
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.phone,
              maxLength: 6, // Setting length of OTP to 6 digits
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20), // Space between TextField and Button

            // Verify OTP Button
            ElevatedButton(
              onPressed: () async {
                try {
                  // Ensure the verificationId is not null before proceeding
                  if (widget.verificationid != null &&
                      _otpController.text.length == 6) {
                    PhoneAuthCredential credential =
                    PhoneAuthProvider.credential(
                      verificationId: widget.verificationid!,
                      smsCode: _otpController.text.trim(),
                    );

                    // Sign in the user using the credential
                    final response = await FirebaseAuth.instance
                        .signInWithCredential(credential);

                    if (response.user?.uid != null) {
                      // Navigate to Home Page after successful OTP verification

                      // check in firebase if user data exist against this uid

                      //if no create it
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) =>  MyHomePage()),
                      );
                    } else {
                      throw Exception('Failed to sign in');
                    }
                  } else {
                    throw Exception('Invalid OTP or verification ID');
                  }
                } on FirebaseAuthException catch (e) {
                  log(e.toString());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Verification failed: ${e.message}")),
                  );
                } catch (ex) {
                  log(ex.toString());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Verification failed: ${ex.toString()}")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(vertical: 15), // Button height
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
