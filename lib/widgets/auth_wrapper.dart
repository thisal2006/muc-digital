import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../screens/services/auth_service.dart'; // Fixed import path
import '../screens/auth/sign_in_screen.dart';
import '../screens/home_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/onboarding_screen.dart';

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
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Show splash for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      bool mustReLogin = await _authService.mustReLoginDueToInactivity();
      if (mustReLogin) {
        await _authService.signOut();
        if (mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingScreen())
          );
        }
      } else {
        await _authService.updateLastActive();

        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();

        if (mounted) {
          if (adminDoc.exists) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen())
            );
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen())
            );
          }
        }
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen())
        );
      }
    }
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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.white,
                  child: const Icon(
                    Icons.apartment,
                    size: 100,
                    color: Colors.white,
                  ),
                );
              },
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
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}