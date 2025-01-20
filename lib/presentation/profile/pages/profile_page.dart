import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../services/upload_to_firebase.dart';

// Define a ChangeNotifier for managing state
class ProfileImageProvider extends ChangeNotifier {
  String? _profileImagePath;

  String? get profileImagePath => _profileImagePath;

  set profileImagePath(String? path) {
    _profileImagePath = path;
    notifyListeners(); // Notify listeners when the path changes
  }
}

// Wrap your app with the ChangeNotifierProvider
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ProfileImageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfilePage(
        onEdit: () {
          // Define what happens on edit
          print('Edit profile pressed');
        },
        onLogout: () {
          // Define what happens on logout
          print('Logout pressed');
        },
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onEdit;

  const ProfilePage({super.key, required this.onLogout, required this.onEdit});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final profileProvider = Provider.of<ProfileImageProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        // Intercept back button press
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Do you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ?? false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/art.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Semi-transparent overlay for readability
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: profileProvider.profileImagePath != null
                              ? FileImage(File(profileProvider.profileImagePath!))
                              : null,
                          backgroundColor: Colors.white12,
                          child: profileProvider.profileImagePath == null
                              ? Text(
                            (user?.displayName?.substring(0, 1) ?? 'U').toUpperCase(),
                            style: const TextStyle(fontSize: 40, color: Colors.white),
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              await _pickImage(context, profileProvider); // Pass context and provider
                            },
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.indigo,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Display user info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      margin: const EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Name Box
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            margin: const EdgeInsets.only(bottom: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.indigo, width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.account_circle,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  user?.displayName ?? 'User Name',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Email Box
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.indigo, width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.email,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  user?.email ?? 'user@example.com',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Edit profile button
                    ElevatedButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(34),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                      ),
                    ),
                    const SizedBox(height: 160),

                    // Logout button
                    ElevatedButton.icon(
                      onPressed: widget.onLogout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Red background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(90.0), // Circular border
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 10.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Function to pick an image from the gallery and update the provider
  Future<void> _pickImage(BuildContext context, ProfileImageProvider provider) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        provider.profileImagePath = pickedFile.path;

        // Upload to Firebase Storage
        String? downloadUrl = await uploadToFirebase(imageFile);
        if (downloadUrl != null) {
          print('Image uploaded successfully. Download URL: $downloadUrl');
          saveProfileImage(downloadUrl); // Save the URL to Firestore
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image upload failed.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> saveProfileImage(String downloadUrl) async {
    try {
      // Save to Firestore
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user?.uid)
          .update({'profileImageUrl': downloadUrl});
      //update users profile on firestore email
      if(user != null && downloadUrl != null){
        await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl);
      }

      print('Profile image URL saved successfully!');
    } catch (e) {
      print('Error saving profile image URL to Firestore: $e');
    }
  }
  }