import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this for AuthWrapper
import '../main.dart';
import '../widgets/auth_wrapper.dart'; // Import to access AuthWrapper
import 'package:shared_preferences/shared_preferences.dart';

class UserAgreementScreen extends StatefulWidget {
  const UserAgreementScreen({super.key});

  @override
  State<UserAgreementScreen> createState() => _UserAgreementScreenState();
}

class _UserAgreementScreenState extends State<UserAgreementScreen> {
  bool _agreed = false;

  Future<void> _acceptAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_agreed', true); // Flag to skip in future

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/sign_in'); // Go to sign in next
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('User Agreement'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Your agreement text here... (full terms, privacy, etc.)',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (val) => setState(() => _agreed = val!),
                ),
                const Text('I agree to the terms'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _agreed ? _acceptAgreement : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Accept & Continue', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}