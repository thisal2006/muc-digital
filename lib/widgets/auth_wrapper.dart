import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/home_screen.dart'; // your home screen

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkBiometricLogin();
  }

  Future<void> _checkBiometricLogin() async {
    final user = _authService.currentUser;

    if (user != null) {
      // User is already signed in to Firebase → try biometric
      final success = await _authService.authenticateWithBiometric();
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // Already logged in → home (biometric already checked in initState)
          return const HomeScreen();
        }

        // Not logged in → show sign in
        return const SignInScreen();
      },
    );
  }
}