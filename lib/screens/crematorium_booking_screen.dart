import 'package:flutter/material.dart';

class CrematoriumBookingScreen extends StatefulWidget {
  const CrematoriumBookingScreen({super.key});

  @override
  State<CrematoriumBookingScreen> createState() => _CrematoriumBookingScreenState();
}

class _CrematoriumBookingScreenState extends State<CrematoriumBookingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crematorium Booking'),
      ),
      body: const Center(
        child: Text('Crematorium Booking - Coming soon (starting point)'),
      ),
    );
  }
}