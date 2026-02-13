// Updated main.dart - fixed const constructors, imports, routing, theme

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:muc_digital/screens/placeholder_screen.dart';
import 'features/garbage_tracking_screen.dart';
import 'firebase_options.dart';
import 'package:muc_digital/screens/property_booking_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/user_agreement_screen.dart';
import 'screens/home_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/announcements_screen.dart';

import 'widgets/app_drawer.dart';  // Make sure this file exists

bool _firebaseInitialized = false;  // Global flag to prevent duplicate calls

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
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) =>  OnboardingScreen(),
        '/user_agreement': (context) => const UserAgreementScreen(),
        '/home': (context) => const HomeScreen(),
        '/emergency': (context) =>  EmergencyScreen(),
        '/announcements': (context) => const AnnouncementsScreen(),
        '/garbage_tracker': (context) => const GarbageTrackingScreen(),
        '/property_booking': (context) => const PlaceholderScreen(title: 'Property Booking'),
        '/vehicle_booking': (context) => const PlaceholderScreen(title: 'Vehicle Booking'),
        '/cemetery_booking': (context) => const PlaceholderScreen(title: 'Cemetery Booking'),
      },
    );
  }
}
