import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/auth_service.dart'; // Import your auth_service

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Wait for splash (3 seconds) while checking
    await Future.delayed(const Duration(seconds: 3));

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Check inactivity
      bool mustReLogin = await _authService.mustReLoginDueToInactivity();
      if (mustReLogin) {
        await _authService.signOut();
        _navigateToSignIn();
      } else {
        // Update last active
        await _authService.updateLastActive();

        // Check if admin
        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();

        if (adminDoc.exists) {
          _navigateToAdminDashboard();
        } else {
          _navigateToHome();
        }
      }
    } else {
      // Not logged in: Go to onboarding (or sign in if you prefer)
      _navigateToOnboarding();
    }
  }

  void _navigateToOnboarding() {
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  void _navigateToSignIn() {
    Navigator.pushReplacementNamed(context, '/sign_in');
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _navigateToAdminDashboard() {
    Navigator.pushReplacementNamed(context, '/admin_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6CA651),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              "MUC Digital",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white), // Show loading during check
          ],
        ),
      ),
    );
  }
}