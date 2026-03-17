import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileManagementService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Logic to update the User's Auth Profile
  Future<void> updateAuthCredentials(String name, String email) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      // Use verifyBeforeUpdateEmail instead of updateEmail
      if (email != user.email) {
        await user.verifyBeforeUpdateEmail(email);
      }
    }
  }

  // Logic to update the Firestore Document (Address/Phone)
  Future<void> updateExtendedProfile(String phone, String address) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'phone': phone,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // Logic to change user's password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      // 1. Create a credential with the old password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // 2. Re-authenticate the user
      await user.reauthenticateWithCredential(credential);
      // 3. Update to the new password
      await user.updatePassword(newPassword);
    }
  }
}