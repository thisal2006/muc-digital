import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'features/Garbage_tracking/garbage_tracking_screen.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/user_agreement_screen.dart';
import 'screens/home_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/announcements_screen.dart';
import 'screens/profile_screen.dart';
import 'features/Property/screens/property_booking_screen.dart';

// Add these new imports (adjust paths if your files are in different folders)
import 'screens/waste_pickup_schedule_screen.dart';           // your new screen
import 'screens/vehicle_booking_screen.dart';               // create this file later
import 'screens/cemetery_booking_screen.dart';              // create this file later
import 'screens/complaints_screen.dart';                    // already exists

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

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/user_agreement': (context) => const UserAgreementScreen(),
        '/home': (context) => const HomeScreen(),
        '/emergency': (context) => const EmergencyScreen(),
        '/announcements': (context) => const AnnouncementsScreen(),
        '/profile': (context) => const ProfileScreen(),

        // Your services (cleaned, no duplicates)
        '/garbage_tracker': (context) => const WastePickupScheduleScreen(),  // ← your main screen
        '/property_booking': (context) => const PropertyBookingScreen(),
        '/vehicle_booking': (context) => const VehicleBookingScreen(),
        '/cemetery_booking': (context) => const CemeteryBookingScreen(),

        // Make complaints consistent with slash
        '/complaints': (context) => const ComplaintsScreen(),
      },
    );
  }
}