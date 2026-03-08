import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  // --- 1. THE EMAILJS FUNCTION ---
  Future<void> _sendApprovalEmail(Map<String, dynamic> data) async {
    // ⚠️ IMPORTANT: This assumes you have a 'contact_email' field saved in Firestore!
    final userEmail = data['contact_email'] ?? 'test@example.com';
    final userName = data['contact_name'] ?? 'Citizen';
    final propertyName = data['property_name'] ?? 'Property';
    final date = data['date'] ?? 'a scheduled date';
    final slot = data['slot'] ?? 'a scheduled time';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': 'service_a0wecoz',
          'template_id': 'template_dbs6us5',
          'user_id': '5H5N3VlVfcyVX3hbD',
          'template_params': {
            'user_name': userName,         // Matches {{user_name}} in your template
            'user_email': userEmail,       // Matches {{user_email}} in your template
            'property_name': propertyName, // Matches {{property_name}} in your template
            'date': date,                  // Matches {{date}} in your template
            'slot': slot,                  // Matches {{slot}} in your template
          }
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Email sent successfully!');
      } else {
        debugPrint('Failed to send email: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
    }
  }

  // --- 2. Updated FIRESTORE FUNCTION ---

  Future<void> _updateBookingStatus(BuildContext context, String docId, String newStatus, Map<String, dynamic> bookingData) async {
    try {
      // Update the database
      await FirebaseFirestore.instance.collection('bookings').doc(docId).update({'status': newStatus});

      // If approved, trigger the email!
      if (newStatus == 'Approved') {
        await _sendApprovalEmail(bookingData);
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booking $newStatus!"),
          backgroundColor: newStatus == 'Approved' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin: Manage Bookings"),
        backgroundColor: Colors.red.shade800, // Danger/Admin color!
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Grabs ALL bookings in the database, newest first
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading bookings"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.red));
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings to manage."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final doc = bookings[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id; // Needed later for updating!

              final propertyName = data['property_name'] ?? 'Unknown';
              final status = data['status'] ?? 'Pending';

              final contactName = data['contact_name'] ?? 'No Name';
              final contactPhone = data['contact_number'] ?? 'No Phone';
              final reason = data['reason'] ?? 'No Reason';
              final date = data['date'] ?? '';
              final slot = data['slot'] ?? '';

              // Dynamic colors for the badge
              Color statusColor = Colors.orange;
              if (status == 'Approved') statusColor = Colors.blue;
              if (status == 'Rejected') statusColor = Colors.red;
              if (status == 'Confirmed') statusColor = Colors.green;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: statusColor.withValues(alpha: 0.5), width: 2)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Property Name & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(propertyName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                          Chip(
                            label: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            backgroundColor: statusColor,
                          ),
                        ],
                      ),
                      const Divider(),

                      // User Details & Reason
                      Text("👤 $contactName", style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text("📞 $contactPhone", style: const TextStyle(color: Colors.blue)),
                      const SizedBox(height: 8),
                      Text("📝 Purpose: $reason", style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 12),

                      // Date and Time
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text("$date | $slot", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),

                      // Action Buttons
                      if (status == 'Pending') ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _updateBookingStatus(context, docId, 'Rejected', data),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                                child: const Text("Reject"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _updateBookingStatus(context, docId, 'Approved', data),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                child: const Text("Approve"),
                              ),
                            ),
                          ],
                        )
                      ]


                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}