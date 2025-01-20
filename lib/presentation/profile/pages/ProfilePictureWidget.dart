import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePicturePage extends StatefulWidget {
  final String initialImageUrl; // Pass the initial profile image URL

  const ProfilePicturePage({Key? key, required this.initialImageUrl})
      : super(key: key);

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  String? _currentImageUrl; // For the currently displayed profile image
  String? _temporaryImage; // Local path of the temporary placeholder
  bool _isUploading = false; // To track upload progress

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.initialImageUrl; // Initialize with the existing profile image
  }

  // Compress the image before upload (Optional, for optimization)
  Future<File?> compressImage(File file) async {
    // You can integrate a package like `flutter_image_compress` here.
    return file; // For simplicity, skipping compression in this example.
  }

  // Function to upload the image to Firebase Storage
  Future<String> uploadToFirebase(File file) async {
    final storageRef =
    FirebaseStorage.instance.ref().child('profile_pictures/${file.path.split('/').last}');
    final uploadTask = await storageRef.putFile(file);
    return await uploadTask.ref.getDownloadURL(); // Get and return the download URL
  }

  // Function to pick an image from the gallery and upload it
  Future<void> updateProfilePicture() async {
    try {
      // Pick an image from the gallery
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return; // User canceled image selection

      final File imageFile = File(pickedFile.path);

      // Show temporary placeholder
      setState(() {
        _temporaryImage = imageFile.path;
        _isUploading = true;
      });

      // Compress the image (Optional, uncomment if compression is implemented)
      // final compressedImage = await compressImage(imageFile);

      // Upload the (compressed) image to Firebase Storage
      final downloadUrl = await uploadToFirebase(imageFile);

      // Update UI with the new profile picture URL
      setState(() {
        _currentImageUrl = downloadUrl;
        _temporaryImage = null; // Clear the placeholder
        _isUploading = false;
      });

      // Notify the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false; // Ensure the loader stops
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile picture: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Picture'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Picture Widget
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _temporaryImage != null
                      ? FileImage(File(_temporaryImage!)) as ImageProvider
                      : CachedNetworkImageProvider(_currentImageUrl ?? ''),
                  child: _isUploading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                      : null,
                ),
                // Edit Icon for Profile Picture
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: updateProfilePicture,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Button to Update Profile Picture
            ElevatedButton(
              onPressed: updateProfilePicture,
              child: const Text('Update Profile Picture'),
            ),
          ],
        ),
      ),
    );
  }
}
