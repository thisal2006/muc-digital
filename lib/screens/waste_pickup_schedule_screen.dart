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
      body: const Center(
        child: Text(
          'Waste Pickup Schedule\n(Work in progress)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}