import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property_model.dart';
import '../services/stripe_service.dart';

class BookingFormScreen extends StatefulWidget {
  final Property property;

  const BookingFormScreen({super.key, required this.property});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime? selectedDate;
  String? selectedSlot;
  bool _agreedToTerms = false;
  bool _isLoadingBookings = true;

  // Store booked slots. Key: Date (YYYY-MM-DD), Value: List of booked slots
  Map<String, List<String>> bookedSlots = {};

  final List<String> timeSlots = [
    "Morning (8:00 AM - 12:00 PM)",
    "Evening (1:00 PM - 5:00 PM)",
    "Night (6:00 PM - 11:00 PM)",
    "Full Day (8:00 AM - 5:00 PM)"
  ];

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _fetchExistingBookings();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}