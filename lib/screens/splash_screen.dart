import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muc_digital/firebase_options.dart';  // Your Firebase config file
import 'package:muc_digital/screens/home_screen.dart';  // Your home screen
import 'package:muc_digital/screens/onboarding_screen.dart';  // Or login screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // 1. Initialize Firebase (connect to your project)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 2. Wait for auth state (check if user is logged in)
      await FirebaseAuth.instance.authStateChanges().first;

      // 3. Navigate based on login status
      if (FirebaseAuth.instance.currentUser != null) {
        // User is logged in → go to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Not logged in → go to onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    } catch (e) {
      // If error (rare), show message or retry
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('App loading error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.orange[700]!],
          ),
        ),
        child: Center(
            child: AnimatedOpacity(
              opacity: 1.0, // starts at 0, fades to 1
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeIn,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.eco, size: 80, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'MUC Digital',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Maharagama Urban Council',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withAlpha(229),
                    ),
                  ),
                  const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: CurvedAnimation(
                      parent: AlwaysStoppedAnimation(1.0),
                      curve: Curves.easeInOut,
                    ),
                    builder: (context, child) {
                      final delay = index * 0.2; // stagger each dot
                      final animationValue = (DateTime.now().millisecondsSinceEpoch / 1000 % 1.2 - delay) % 1.2;
                      final opacity = (animationValue * 5).clamp(0.3, 1.0); // pulse from 0.3 to 1.0
                      final scale = 1.0 + (animationValue * 0.4); // slight grow/shrink

                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withAlpha(120),
                                  blurRadius: 12,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}