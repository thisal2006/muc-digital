import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  // --- STRIPE PAYMENT LOGIC ---
  Future<void> makePayment(BuildContext context, String priceStr, String bookingId) async {
    try {
      // 1. Initialize the Payment Sheet
      // Note: In production, 'paymentIntentClientSecret' must come from your server/cloud function
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: const SetupPaymentSheetParameters(
          paymentIntentClientSecret: "pi_test_placeholder_secret", // Dummy for now
          merchantDisplayName: 'MUC Digital',
          style: ThemeMode.light,
        ),
      );

      // 2. Display the Stripe UI
      await Stripe.instance.presentPaymentSheet();

      // 3. Update Firestore if successful
      await FirebaseFirestore.instance
          .collection('bookings')
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: const Color(0xFFE67E22),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('user_id', isEqualTo: 'current_user_id')
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

              final propertyName = data['property_name'] ?? 'Unknown Venue';
              final date = data['date'] ?? 'No date';
              final slot = data['slot'] ?? 'No slot';
              final price = data['price'] ?? 'LKR 0';

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
                          // The Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor, width: 1),
                            ),
                            child: Text(
                              displayStatus.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
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
                      const Divider(height: 32, thickness: 0.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "BOOKING REF",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Text(
                            bookings[index].id.substring(0, 8).toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace', // Gives it that digital receipt look
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
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
          style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal
          ),
        ),
      ],
    );
  }
}

//good to go.