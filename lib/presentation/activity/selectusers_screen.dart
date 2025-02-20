import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart'; // Import your chat screen

class SelectUserScreen extends StatefulWidget {
  @override
  _SelectUserScreenState createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isChecking = false;
  String? _errorMessage;

  void _checkUserAndNavigate() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      String enteredEmail = _emailController.text.trim();
      if (enteredEmail.isEmpty) {
        setState(() {
          _errorMessage = "Please enter an email address.";
          _isChecking = false;
        });
        return;
      }

      // Query Firestore to check if the user exists
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: enteredEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String receiverId = querySnapshot.docs.first.id;

        if (receiverId == _auth.currentUser!.uid) {
          setState(() {
            _errorMessage = "You cannot chat with yourself!";
            _isChecking = false;
          });
          return;
        }

        // Navigate to chat screen with selected user
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiverId: receiverId,
              receiverEmail: enteredEmail,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = "User not found!";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select User")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Enter User's Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isChecking ? null : _checkUserAndNavigate,
              child: _isChecking ? CircularProgressIndicator() : Text("Start Chat"),
            ),
          ],
        ),
      ),
    );
  }
}
