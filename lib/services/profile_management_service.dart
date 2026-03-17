import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileManagementService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user data
  Stream<DocumentSnapshot> getUserData() {
    String uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // Update Profile Name and Phone
  Future<void> updateProfile(String name, String phone) async {
    String uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'phone': phone,
    });
  }
}