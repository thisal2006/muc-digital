import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email/password
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
        'biometricEnabled': false, // default false
      });

      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email/password
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

  // Enable biometric login (called after signup or from settings)
  Future<bool> enableBiometric() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();

      if (!canAuthenticate || !isSupported) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to enable quick login',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );

      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_enabled', true);

        // Also save in Firestore (optional)
        if (_auth.currentUser != null) {
          await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).update({
            'biometricEnabled': true,
          });
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Biometric enable error: $e');
      return false;
    }
  }

  // Check if biometric is enabled and authenticate
  Future<bool> tryBiometricLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('biometric_enabled') ?? false;

      if (!enabled) return false;

      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to log in',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (e) {
      print('Biometric login error: $e');
      return false;
    }
  }

  // Sign out (also disable biometric)
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('biometric_enabled');
  }
}