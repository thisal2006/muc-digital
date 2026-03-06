import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin: Manage Bookings"),
        backgroundColor: Colors.red.shade800, // Danger/Admin color!
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Ready to connect to Firebase!"),
      ),
    );
  }
}