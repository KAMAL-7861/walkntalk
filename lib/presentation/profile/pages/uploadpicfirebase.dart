import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/upload_to_firebase.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  String? _imageUrl;

  Future<void> _pickImage() async {
    // Assuming you have already set up the image_picker plugin
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Upload image and get the download URL
      String? downloadUrl = await uploadToFirebase(_imageFile!);
      if (downloadUrl != null) {
        setState(() {
          _imageUrl = downloadUrl;
        });
        print('Profile image uploaded successfully: $_imageUrl');
      } else {
        print('Error uploading profile image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile != null
                ? Image.file(_imageFile!)
                : const Text('No image selected'),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick an Image'),
            ),
            if (_imageUrl != null) Text('Image URL: $_imageUrl'),
          ],
        ),
      ),
    );
  }
}
