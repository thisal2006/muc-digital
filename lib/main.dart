import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:muc_digital/widgets/auth_wrapper.dart';
import 'chatbot.dart';
import 'features/Garbage_tracking/garbage_tracking_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
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
import 'screens/settings_screen.dart';
import 'package:muc_digital/features/crematorium%20booking/crematorium_booking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/booking_history_screen.dart';
import 'widgets/app_drawer.dart';
import 'vehicleBooking/vehicle_type_screen.dart';

bool _firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = "pk_test_51SzuZY0KRpwcO4zEHs47arkmOTryBOAhNWAgBo2nAHdd2bwvIkoaPhoHnTuJFMhj1B4aB6RqfMaIJkmBsL8R0ERW008fqqSwg4";

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
        '/': (context) => const AuthWrapper(),
        '/onboarding': (context) => OnboardingScreen(),
        '/user_agreement': (context) => const UserAgreementScreen(),
        '/home': (context) => const HomeScreen(),
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
        '/settings': (context) => const SettingsScreen(),
        '/booking-history': (context) => const BookingHistoryScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
/*        '/crematorium_booking': (context) => const CrematoriumBookingScreen(),*/
        '/vehicle_booking': (context) => const VehicleTypeScreen(),

      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text(
                'Route not found: ${settings.name}\n\nCheck main.dart routes!',
                style: const TextStyle(fontSize: 18, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}