import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen for auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current logged-in user
  User? get currentUser => _auth.currentUser;

  // Sign in with email & password
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Update last active time on successful login
      await _updateLastActive();

      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email & password
  Future<User?> signUp(String email, String password, String name, String phone) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Optional: save extra user info to Firestore
      // await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
      //   'name': name.trim(),
      //   'phone': phone.trim(),
      //   'createdAt': FieldValue.serverTimestamp(),
      // });

      // Update last active
      await _updateLastActive();

      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Check if user must re-login due to inactivity (10 days)
  Future<bool> mustReLoginDueToInactivity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveMillis = prefs.getInt('last_active_timestamp') ?? 0;

    if (lastActiveMillis == 0) return true; // first time ever

    final lastActive = DateTime.fromMillisecondsSinceEpoch(lastActiveMillis);
    final now = DateTime.now();

    final daysInactive = now.difference(lastActive).inDays;
    return daysInactive >= 10;
  }

  // Update last active timestamp (call after every successful login)
  Future<void> _updateLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_active_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  // Sign out (also clear timestamp)
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_active_timestamp');
  }
}