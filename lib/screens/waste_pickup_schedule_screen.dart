import 'package:flutter/material.dart';

class WastePickupScheduleScreen extends StatefulWidget {
  const WastePickupScheduleScreen({super.key});

  @override
  State<WastePickupScheduleScreen> createState() => _WastePickupScheduleScreenState();
}

class _WastePickupScheduleScreenState extends State<WastePickupScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Pickup Schedule'),
        backgroundColor: const Color(0xFF1B5E20), // match app theme
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
        // Placeholder header for calendar section
        Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Colors.green[50],
        child: const Text(
          'Select a date for pickup schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}