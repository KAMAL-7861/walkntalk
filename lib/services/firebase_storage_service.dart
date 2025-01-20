import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:walkntalk/services/upload_to_firebase.dart'; // Make sure to add the
// image_picker dependency

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  String? _imageUrl;

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Upload the image to Firebase Storage
      String? downloadUrl = await uploadToFirebase(_imageFile!);
      if (downloadUrl != null) {
        setState(() {
          _imageUrl = downloadUrl;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile != null
                ? Image.file(_imageFile!)
                :const  Text("No image selected."),
            ElevatedButton(
              onPressed: _pickImage,
              child:const Text("Pick an Image"),
            ),
            if (_imageUrl != null) Text("Image URL: $_imageUrl"),
          ],
        ),
      ),
    );
  }
}
