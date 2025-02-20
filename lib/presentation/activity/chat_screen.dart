import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverEmail;

  ChatScreen({required this.receiverId, required this.receiverEmail});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  late String currentUserId;
  late String messageText;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser!.uid;
  }

  void sendMessage() async {
    if (messageText.trim().isNotEmpty) {
      try {
        await _firestore.collection('messages').add({
          'text': messageText,
          'senderId': currentUserId,
          'receiverId': widget.receiverId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _messageController.clear();
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with ${widget.receiverEmail}")),
      body: Column(
        children: [
          Expanded(child: MessagesStream(currentUserId, widget.receiverId)),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.lightBlueAccent, width: 2.0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (value) {
                      messageText = value;
                    },
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: sendMessage,
                  child: Text("Send", style: TextStyle(color: Colors.lightBlueAccent)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  final String currentUserId;
  final String receiverId;

  MessagesStream(this.currentUserId, this.receiverId);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .where('senderId', whereIn: [currentUserId, receiverId])
          .where('receiverId', whereIn: [currentUserId, receiverId])
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;
        List<MessageBubble> messageWidgets = [];

        for (var message in messages) {
          final messageText = message['text'];
          final senderId = message['senderId'];

          final messageWidget = MessageBubble(
            text: messageText,
            isMe: senderId == currentUserId,
          );
          messageWidgets.add(messageWidget);
        }

        return ListView(
          reverse: true,
          padding: EdgeInsets.all(10.0),
          children: messageWidgets,
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  MessageBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            )
                : BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            elevation: 5.0,
            color: isMe ? Colors.green : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(fontSize: 15.0, color: isMe ? Colors.white : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
