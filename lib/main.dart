// Updated main.dart - with AuthWrapper integration

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:muc_digital/widgets/auth_wrapper.dart';
import 'features/Garbage_tracking/garbage_tracking_screen.dart';
import 'features/Property/screens/my_bookings_screen.dart';
import 'firebase_options.dart';
import 'screens/onboarding_screen.dart';
import 'screens/user_agreement_screen.dart';
import 'screens/home_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/announcements_screen.dart';
import 'screens/profile_screen.dart';
import 'features/Property/screens/property_booking_screen.dart';
import 'screens/phone_login_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
//import 'screens/my_bookings_screen.dart'; // Keep this for navigation

bool _firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!_firebaseInitialized) {
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('Firebase initialized successfully');
      } catch (e) {
        debugPrint('Firebase init failed: $e');
      }
      _firebaseInitialized = true;
    } else {
      debugPrint('Firebase already initialized - skipping');
    }
  }

  runApp(const MUCdigitalApp());
}

class MUCdigitalApp extends StatelessWidget {
  const MUCdigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MUC Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green[700]!,
          primary: Colors.green[700],
          secondary: Colors.orange[700],
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 46, 125, 50),
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/onboarding': (context) => OnboardingScreen(),
        '/user_agreement': (context) => const UserAgreementScreen(),
        '/home': (context) => const HomeScreen(), // CRITICAL: This was missing
        '/emergency': (context) => EmergencyScreen(),
        '/announcements': (context) => const AnnouncementsScreen(),
        '/garbage_tracker': (context) => const GarbageTrackingScreen(),
        '/property_booking': (context) => const PropertyBookingScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/phone_login': (context) => const PhoneLoginScreen(),
        '/otp_verification': (context) => OTPVerificationScreen(
          verificationId: '',
          phoneNumber: '',
        ),
        '/sign_in': (context) => const SignInScreen(),
        '/sign_up': (context) => const SignUpScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/my_bookings': (context) => const MyBookingsScreen(), // Un-commented and fixed
      },
    );
  }
}