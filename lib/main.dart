import 'package:flutter/material.dart';
import 'features/Property/screens/property_booking_screen.dart';

void main() {
  runApp(const MUCdigitalApp());
}

class MUCdigitalApp extends StatelessWidget {
  const MUCdigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MUC Digital',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE67E22)),
        useMaterial3: true,
      ),
      home: const PropertyBookingScreen(),
    );
  }
}