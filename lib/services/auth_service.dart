import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if user is logged in
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up
  Future<User?> signUp(String email, String password, String name, String phone) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'biometricEnabled': false,
      });

      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Enable biometric after login
  Future<bool> enableBiometric() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canAuthenticate || !isDeviceSupported) {
        return false;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Enable fingerprint login for faster access',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometricEnabled', true);
        await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).update({
          'biometricEnabled': true,
        });
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check & authenticate with biometric
  Future<bool> authenticateWithBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('biometricEnabled') ?? false;

      if (!enabled) return false;

      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Scan fingerprint to login',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('biometricEnabled');
  }
}