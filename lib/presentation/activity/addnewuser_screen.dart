import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:walkntalk/presentation/activity/chat_screen.dart';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  Future<void> checkUserAndStartChat() async {
    String email = _emailController.text.trim().toLowerCase();
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    if (email.isEmpty) {
      setState(() {
        errorMessage = "Please enter an email!";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Debug print statement
      print("Searching Firestore for email: $email");

      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        String receiverId = userQuery.docs.first.id;
        print("User found! ID: $receiverId");

        // Check if chat already exists between these two users
        var chatQuery = await FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .get();

        String? chatId;

        for (var doc in chatQuery.docs) {
          List participants = doc['participants'];
          if (participants.contains(receiverId)) {
            chatId = doc.id;
            break;
          }
        }

        if (chatId == null) {
          // If chat doesn't exist, create a new one
          print("Creating new chat...");
          var newChatDoc = await FirebaseFirestore.instance.collection('chats').add({
            'participants': [currentUserId, receiverId],
            'lastMessage': "",
            'timestamp': FieldValue.serverTimestamp(),
          });
          chatId = newChatDoc.id;
        }

        // Navigate to chat screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiverId: receiverId,
              receiverEmail: email,
            ),
          ),
        );
      } else {
        print("User not found!");
        setState(() {
          errorMessage = "User not found!";
        });
      }
    } catch (e) {
      print("Error fetching user: $e");
      setState(() {
        errorMessage = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Chat")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Enter User's Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            if (errorMessage != null)
              Text(errorMessage!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: checkUserAndStartChat,
              child: Text("Start Chat"),
            ),
          ],
        ),
      ),
    );
  }
}
