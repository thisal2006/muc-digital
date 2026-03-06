import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                    side: BorderSide(color: statusColor.withOpacity(0.5), width: 2)
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

                      // CHUNK 4 DETAILS WILL GO HERE
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