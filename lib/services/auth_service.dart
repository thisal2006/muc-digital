import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen for auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign in
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await updateLastActive(); // public method
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up
  Future<User?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await updateLastActive(); // public method
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Check if user must re-login (inactive 10 days)
  Future<bool> mustReLoginDueToInactivity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveMillis = prefs.getInt('last_active_timestamp') ?? 0;

    if (lastActiveMillis == 0) return true; // first time

    final lastActive = DateTime.fromMillisecondsSinceEpoch(lastActiveMillis);
    final now = DateTime.now();

    return now.difference(lastActive).inDays >= 10;
  }

  // Public method to update last active timestamp
  Future<void> updateLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_active_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_active_timestamp');
  }
}