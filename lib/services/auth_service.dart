import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if user is already logged in
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email/password
  Future<User?> signInWithEmail(String email, String password) async {
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

  // Sign up with email/password
  Future<User?> signUpWithEmail(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // You can save name to Firestore here if needed
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Enable biometric login (called after successful signup or manual enable)
  Future<bool> enableBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isSupported) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to enable quick login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_enabled', true);
        return true;
      }
      return false;
    } catch (e) {
      print('Biometric enable error: $e');
      return false;
    }
  }

  // Try biometric login (called on app start or sign-in page)
  Future<bool> authenticateWithBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('biometric_enabled') ?? false;

      if (!enabled) return false;

      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Scan fingerprint to log in',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print('Biometric auth error: $e');
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