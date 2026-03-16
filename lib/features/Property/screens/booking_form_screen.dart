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
    _fetchExistingBookings();
  }

  Future<void> _fetchExistingBookings() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('property_bookings')
          .where('property_name', isEqualTo: widget.property.name)
          .where('status', isEqualTo: 'Paid') // Only block officially paid slots
          .get();

      Map<String, List<String>> tempBooked = {};

      for (var doc in snapshot.docs) {
        String date = doc['date'];
        String slot = doc['slot'];

        if (!tempBooked.containsKey(date)) {
          tempBooked[date] = [];
        }
        tempBooked[date]!.add(slot);
      }

      setState(() {
        bookedSlots = tempBooked;
        _isLoadingBookings = false;
      });
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
      setState(() => _isLoadingBookings = false);
    }
  }

  String get _calculatedPrice {
    if (selectedSlot == null) return widget.property.price;
    String rawPriceString = widget.property.price.replaceAll(RegExp(r'[^0-9]'), '');
    int basePrice = int.tryParse(rawPriceString) ?? 0;
    int finalPrice = selectedSlot!.contains('Full Day') ? (basePrice * 2) : basePrice;

    String formattedPrice = finalPrice.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    );
    return 'LKR $formattedPrice';
  }

  Future<void> _callCouncil() async {
    final Uri url = Uri.parse('tel:${widget.property.contactNumber.replaceAll(" ", "")}');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open phone dialer")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

// --- PASTE CLUSTER 3 HERE ---