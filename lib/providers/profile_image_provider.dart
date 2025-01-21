import 'dart:developer';
import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:walkntalk/main.dart';
import '../firebase_options.dart';

late FirebaseApp app;
late FirebaseAuth auth;

class ProfileImageProvider extends ChangeNotifier {
  String? _profileImageUrl;

  String? get profileImageUrl => _profileImageUrl;

  set profileImageUrl(String? url) {
    _profileImageUrl = url;
    notifyListeners(); // Notify listeners of the change
  }

  Future<void> loadProfileImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final imageUrl = doc.data()?['profileImageUrl'] as String?;
       log('got image: $imageUrl');
        if (imageUrl != null) {
          profileImageUrl = imageUrl;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading profile image: $e');
      }
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
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'profileImageUrl': downloadUrl});
          profileImageUrl = downloadUrl; // Update provider state
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving profile image: $e');
      }
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
      if (kDebugMode) {
        print('Error uploading to Firebase Storage: $e');
      }
      return null;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    auth = FirebaseAuth.instanceFor(app: app);

    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('CC0CB3E4-971C-467F-9906-29C5D79C6F99'),
    );

    runApp(
      ChangeNotifierProvider(
        create: (_) => ProfileImageProvider()..loadProfileImage(),
        child: const MyApp(isLoggedIn: true),
      ),
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Firebase: $e');
    }
  }
}
