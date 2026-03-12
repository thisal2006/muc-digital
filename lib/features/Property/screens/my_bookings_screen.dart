import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // Make sure this is in pubspec.yaml

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  // --- STRIPE PAYMENT FUNCTION ---
  Future<void> makePayment(BuildContext context, String priceStr) async {
    try {
      // STEP 1: You must create a PaymentIntent on your server/backend here!
      // Example: final paymentIntent = await callYourCloudFunction(priceStr);

      // FOR NOW: This is placeholder data that your backend WOULD return
      final clientSecret = "pi_YOUR_SECRET_FROM_BACKEND";

      // STEP 2: Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'MUC Digital',
          // Add your Stripe publishable key in your main.dart!
        ),
      );

      // STEP 3: Display the Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful!", style: TextStyle(color: Colors.green))),
      );

      // STEP 4: Update the Firestore document to 'Confirmed' here!

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed or canceled: $e")),
      );
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
            .where('user_id', isEqualTo: 'current_user_id') // Make sure this matches your actual auth ID!
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)));
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text("You have no bookings yet.", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;

              final propertyName = data['property_name'] ?? 'Unknown Property';
              final date = data['date'] ?? 'No date';
              final slot = data['slot'] ?? 'No slot';
              final price = data['price'] ?? 'LKR 0';

              // FIX 1: Normalize status to lowercase so it always matches
              final rawStatus = data['status'] ?? 'pending';
              final status = rawStatus.toString().toLowerCase();

              Color statusColor = Colors.orange;
              if (status == 'approved') statusColor = Colors.blue;
              if (status == 'confirmed') statusColor = Colors.green;
              if (status == 'rejected') statusColor = Colors.red;

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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              // Capitalize the first letter for the UI
                              status[0].toUpperCase() + status.substring(1),
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(date, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(slot, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // FIX 2: Close the Row here!
                      Row(
                        children: [
                          const Icon(Icons.payments_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),

                      // FIX 2: Move the button OUTSIDE the Row so it doesn't cause a RenderFlex overflow
                      if (status == 'approved') ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => makePayment(context, price),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Pay Now to Confirm"),
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
}