import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:firebase_auth/firebase_auth.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  // --- STRIPE PAYMENT LOGIC ---
  Future<void> makePayment(BuildContext context, String priceStr, String bookingId) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: const SetupPaymentSheetParameters(
          paymentIntentClientSecret: "pi_test_placeholder_secret",
          merchantDisplayName: 'MUC Digital',
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Inside makePayment function:
      await FirebaseFirestore.instance
          .collection('property_bookings') // Change 'bookings' to 'property_bookings'
          .doc(bookingId)
          .update({'status': 'Paid'});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Successful!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Payment Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get the actual logged-in user's ID
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String userId = currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: const Color(0xFFE67E22),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('property_bookings') // Double check if it's 'bookings' or 'property_bookings'
            .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid) // Match the index name!
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)));
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    "No pending or active bookings",
                    style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;
              final String docId = bookings[index].id; // Reference for payment

              final propertyName = data['property_name'] ?? 'Unknown Venue';
              final date = data['date'] ?? 'No date';
              final slot = data['slot'] ?? 'No slot';
              final price = data['price'] ?? 'LKR 0';
              final purpose = data['purpose'] ?? 'Not specified';
              //final crowd = data['crowd_size'] ?? '0';


              final String status = data['status'] ?? 'Approval Pending';
              Color statusColor = Colors.orange;
              String displayStatus = status;

              if (status == 'Approved, Payment Pending') {
                statusColor = Colors.blue;
              } else if (status == 'Paid' || status == 'Confirmed') {
                statusColor = Colors.green;
                displayStatus = "Paid & Confirmed";
              } else if (status == 'Rejected') {
                statusColor = Colors.red;
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              propertyName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor, width: 1),
                            ),
                            child: Text(
                              displayStatus.toUpperCase(),
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(Icons.calendar_today, date),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.access_time, slot),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.payments_outlined, price, isBold: true),

                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.info_outline, "Purpose: $purpose"),
                      const SizedBox(height: 8),
                     // _buildDetailRow(Icons.people_outline, "Crowd: $crowd"),
                      const Divider(height: 32, thickness: 0.5),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "BOOKING REF",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.1),
                          ),
                          Text(
                            docId.substring(0, 8).toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey),
                          ),
                        ],
                      ),

                      // --- PAYMENT BUTTON SECTION ---
                      if (status == 'Approved, Payment Pending') ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => makePayment(context, price, docId),
                            icon: const Icon(Icons.payment_rounded),
                            label: const Text("Pay Now to Confirm Booking"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDetailRow(IconData icon, String text, {bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}