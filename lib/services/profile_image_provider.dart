import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:walkntalk/main.dart';
import '../firebase_options.dart';

late FirebaseApp app;
late FirebaseAuth auth;

class ProfileImageProvider extends ChangeNotifier {
  String? profileImageUrl;

  void updateProfileUrl(String? url) {
    profileImageUrl = url;
    notifyListeners(); // Notify listeners of the change
  }

  Future<void> loadProfileImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final photoUrl = user.photoURL;
        if (photoUrl == null) {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          if (doc.exists) {
            final imageUrl = doc.data()?['profileImageUrl'] as String?;
            if (imageUrl != null) {
              updateProfileUrl(imageUrl);
            }
          }
        } else {
          updateProfileUrl(photoUrl);
        }
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  Future<void> saveProfileImage(File file) async {
    try {
      // Upload to Firebase Storage
      String? downloadUrl = await uploadToFirebase(file);
      if (downloadUrl != null) {
        // Save the URL to Firestore
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid);
          final getDoc = await doc.get();
          final previousProfileImage = getDoc.data()?['profileImageUrl'] as String?;
          ///delete previous image first
          if (previousProfileImage != '') {
            deleteImageFromFirebase(previousProfileImage!);
          }

          doc.update({'profileImageUrl': downloadUrl});
          profileImageUrl = downloadUrl; //or
          updateProfileUrl(downloadUrl);

          //update users profile on firestore email
          if (user != null && downloadUrl != null) {
            await user.updatePhotoURL(downloadUrl);
          }
        }
      }
    } catch (e) {
      print('Error saving profile image: $e');
    }
  }

  Future<String?> uploadToFirebase(File file) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures/${file.path.split('/').last}');
      final uploadTask = await storageRef.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading to Firebase Storage: $e');
      return null;
    }
  }

  ///delete previous image
  Future<void> deleteImageFromFirebase(String url) async {
    final ref = FirebaseStorage.instance.refFromURL(url);
    final res = await ref.delete();

    ///no checks for res for now
  }
}
