import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'crematorium_booking_data.dart';

class CrematoriumContactScreen extends StatelessWidget {
  final CrematoriumBookingData bookingData;

  const CrematoriumContactScreen({super.key, required this.bookingData});

  Future<void> _callCouncil() async {
    final Uri telUri = Uri.parse('tel:+94112850265');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = bookingData.selectedDate != null
        ? "${bookingData.selectedDate!.day}/${bookingData.selectedDate!.month}/${bookingData.selectedDate!.year}"
        : "Not selected";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Council'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Booking Request Submitted Successfully!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: $date'),
                    Text('Time Slot: ${bookingData.timeSlot ?? "Unknown"}'),
                    Text('Resident: ${bookingData.isResident ? "Yes" : "No"}'),
                    Text('Relation: ${bookingData.relation ?? "Unknown"}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'To confirm your crematorium slot,\nplease contact the Maharagama Urban Council Crematorium Section:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '011 285 0265',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.phone, color: Colors.white),
                label: const Text('Call Council Now'),
                onPressed: _callCouncil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}