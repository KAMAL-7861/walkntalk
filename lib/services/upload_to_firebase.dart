import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

// Function to upload image to Firebase Storage
Future<String?> uploadToFirebase(File file) async {
  try {
    // Get the file name from the path
    String fileName = file.path.split('/').last;

    // Ensure the file has a valid extension
    if (!fileName.endsWith('.jpg') && !fileName.endsWith('.jpeg') && !fileName.endsWith('.png')) {
      fileName += '.jpg';  // Default to .jpg if no valid extension is found
    }

    // Reference to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$fileName');

    // Upload task
    final uploadTask = storageRef.putFile(file);

    // Optionally, track the upload progress
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
      if (kDebugMode) {
        print('Upload is $progress% complete.');
      }
    });

    // Wait for the upload to finish and get the download URL
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    if (kDebugMode) {
      print('File uploaded successfully. Download URL: $downloadUrl');
    }
    return downloadUrl;  // Return the download URL of the uploaded file
  } catch (e) {
    if (kDebugMode) {
      print('Error uploading file to Firebase: $e');
    }
    return null;  // Return null in case of an error
  }
}
