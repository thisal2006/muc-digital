import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/stripe_service.dart';
import 'package:muc_digital/models/property_model.dart';

class BookingFormScreen extends StatefulWidget {
  final Property property;

  const BookingFormScreen({super.key, required this.property});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime? selectedDate;
  String? selectedSlot;
  final List<String> timeSlots = [
    "Morning (8:00 AM - 12:00 PM)",
    "Evening (1:00 PM - 5:00 PM)",
    "Full Day (8:00 AM - 5:00 PM)"];

  // Controller for user details
  final TextEditingController _reasonController = TextEditingController();

  // Helper to pick date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)), // Default to tomorrow
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE67E22), // Orange header
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  //Function to save booking to firebase
  Future<void> _saveBooking() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22))),
    );

    try {
      final bookingData = {
        "property_name": widget.property.name,
        "price": widget.property.price,
        "date": selectedDate.toString().split(' ')[0],
        "slot": selectedSlot,
        "reason": _reasonController.text,
        "status": "Confirmed",
        "timestamp": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('bookings').add(bookingData);

      Navigator.of(context).pop(); // Close loader

      _showSuccessDialog(); // Show success popup

    } catch (e) {
      Navigator.of(context).pop(); // Close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: $e")),
      );
    }
  }
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
        title: const Text("Booking Confirmed!"),
        content: const Text("Your booking has been paid for and saved to the Council database."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Request Booking"),
          backgroundColor: const Color(0xFFE67E22),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // PROPERTY SUMMARY CARD
          Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(widget.property.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.property.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.property.price, style: const TextStyle(color: Color(0xFFE67E22), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // DATE PICKER
        const Text("Select Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? "Tap to choose a date"
                      : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
                  style: TextStyle(color: selectedDate == null ? Colors.grey : Colors.black, fontSize: 16),
                ),
                const Icon(Icons.calendar_today, color: Color(0xFFE67E22)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // TIME SLOT
        const Text("Select Time Slot", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          hint: const Text("Choose a slot"),
          initialValue: selectedSlot,
          items: timeSlots.map((String slot) {
            return DropdownMenuItem<String>(value: slot, child: Text(slot));
          }).toList(),
          onChanged: (newValue) => setState(() => selectedSlot = newValue),
        ),
        const SizedBox(height: 20),

                // REASON FIELD
                const Text("Purpose of Booking", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    hintText: "E.g., Wedding reception, Annual meeting...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 3,
                ),
              ],
          ),
        ),

      // BOTTOM BUTTON (STRIPE INTEGRATED)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: (selectedDate != null && selectedSlot != null)
              ? () async {
            // 1. Call Stripe
            await StripeService.makePayment(
              context,
              widget.property.price,
                  () {
                // 2. If Payment Success -> Save to Firebase
                _saveBooking();
              },
            );
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE67E22),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
          ),
          child: const Text("Pay & Book Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

