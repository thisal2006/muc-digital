import 'package:flutter/material.dart';
import 'email_login_screen.dart';
import 'phone_login_screen.dart'; // optional - keep if you want phone later

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome Back!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue using MUC Digital',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // Email Login Button
              ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Continue with Email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmailLoginScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Phone Login Button (optional - uncomment if you want it back)
              /*
              OutlinedButton.icon(
                icon: const Icon(Icons.phone_android),
                label: const Text('Continue with Phone'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B5E20),
                  side: const BorderSide(color: Color(0xFF1B5E20)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
              */

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EmailLoginScreen(isSignUp: true)),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}