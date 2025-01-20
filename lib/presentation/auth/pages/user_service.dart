import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  // Get user profile
  Future<DocumentSnapshot> getUserProfile(String uid) {
    return _usersCollection.doc(uid).get();
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    return _usersCollection.doc(uid).update(data);
  }
}
