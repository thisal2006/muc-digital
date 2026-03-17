import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileManagementService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Update Auth Name/Email
  Future<void> updateAuthCredentials(String name, String email) async {
    User? user = _auth.currentUser;
    if (user != null) {
      if (name.isNotEmpty) await user.updateDisplayName(name);
      if (email.isNotEmpty && email != user.email) await user.verifyBeforeUpdateEmail(email);
    }
  }

  // 2. Update Firestore Phone/Address
  Future<void> updateExtendedProfile(String phone, String address) async {
    String uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).set({
      'phone': phone,
      'address': address,
    }, SetOptions(merge: true));
  }

  // 3. Change Password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    }
  }
}