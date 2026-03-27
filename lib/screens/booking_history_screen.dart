import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Booking History'),
          backgroundColor: const Color(0xFF1B5E20),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Please log in to view your booking history.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getAllBookingsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Something went wrong: ${snapshot.error}'),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No bookings yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Your future bookings will appear here', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index];
              final source = data['source_collection'];
              
              // Determine UI properties based on source
              String title = 'Booking';
              String subtitle = '';
              String amount = '0.00';
              String status = data['status'] ?? 'Pending';
              IconData categoryIcon = Icons.book_online;
              String dateInfo = 'Date not specified';
              String timeInfo = '';

              if (source == 'property_bookings') {
                title = data['property_name'] ?? 'Property Booking';
                amount = data['price'] ?? '0.00';
                dateInfo = data['date'] ?? 'Date not specified';
                timeInfo = data['slot'] ?? '';
                categoryIcon = Icons.apartment;
              } else if (source == 'crematorium_bookings') {
                title = 'Crematorium Booking';
                amount = 'Fixed Fee'; // Or get from data if available
                categoryIcon = Icons.church;
                
                final dynamic d = data['date'];
                if (d is Timestamp) {
                  dateInfo = DateFormat('dd MMM yyyy').format(d.toDate());
                } else {
                  dateInfo = d?.toString() ?? 'Date not specified';
                }
                timeInfo = data['timeSlot'] ?? '';
              } else if (source == 'bookings') {
                // Vehicle Booking
                categoryIcon = Icons.directions_car;
                final vehicle = data['vehicleDetails'];
                if (vehicle != null) {
                  title = "${vehicle['brand'] ?? ''} ${vehicle['model'] ?? ''}".trim();
                  if (title.isEmpty) title = "Vehicle Booking";
                } else {
                  title = data['bookingType'] ?? "Vehicle Booking";
                }
                
                amount = "LKR ${data['totalPrice'] ?? data['amount'] ?? '0.00'}";
                dateInfo = "${data['startDate'] ?? ''} - ${data['endDate'] ?? ''}";
                status = data['status'] ?? 'PENDING';
              }

              // Unified Status Color
              Color statusColor;
              final normalizedStatus = status.toLowerCase();
              if (['confirmed', 'completed', 'paid', 'approved'].contains(normalizedStatus)) {
                statusColor = Colors.green;
              } else if (['cancelled', 'rejected', 'failed'].contains(normalizedStatus)) {
                statusColor = Colors.red;
              } else {
                statusColor = Colors.orange;
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(categoryIcon, color: const Color(0xFF1B5E20), size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            dateInfo,
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                      if (timeInfo.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              timeInfo,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            source.toString().split('_')[0].toUpperCase(),
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            amount.startsWith('LKR') ? amount : 'LKR $amount',
                            style: const TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              color: Color(0xFF1B5E20)
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

  /// Combined stream from all 3 collections
  Stream<List<Map<String, dynamic>>> _getAllBookingsStream() {
    final userId = user?.uid;
    
    // 1. Property Bookings
    final propertyStream = FirebaseFirestore.instance
        .collection('property_bookings')
        .where('user_id', isEqualTo: userId)
        .snapshots();

    // 2. Crematorium Bookings
    final crematoriumStream = FirebaseFirestore.instance
        .collection('crematorium_bookings')
        .where('userId', isEqualTo: userId)
        .snapshots();

    // 3. Vehicle Bookings
    // Note: If vehicle bookings are only in the API, we might need to handle it differently.
    // However, assuming they are also mirrored in Firestore 'bookings' as per typical logic here.
    final vehicleStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots();

    return _zipStreams([propertyStream, crematoriumStream, vehicleStream]).map((snapshots) {
      final List<Map<String, dynamic>> allBookings = [];

      final collections = ['property_bookings', 'crematorium_bookings', 'bookings'];

      for (int i = 0; i < snapshots.length; i++) {
        for (var doc in snapshots[i].docs) {
          var data = doc.data() as Map<String, dynamic>;
          data['source_collection'] = collections[i];
          data['doc_id'] = doc.id;
          allBookings.add(data);
        }
      }

      // Sort by timestamp (newest first)
      allBookings.sort((a, b) {
        DateTime? dateA = _getDateTime(a);
        DateTime? dateB = _getDateTime(b);
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });

      return allBookings;
    });
  }

  DateTime? _getDateTime(Map<String, dynamic> data) {
    try {
      if (data['timestamp'] is Timestamp) return (data['timestamp'] as Timestamp).toDate();
      if (data['createdAt'] is Timestamp) return (data['createdAt'] as Timestamp).toDate();
      if (data['createdAt'] is String) return DateTime.tryParse(data['createdAt']);
      
      final dynamic dateField = data['date'];
      if (dateField is Timestamp) return dateField.toDate();
      if (dateField is String) return DateTime.tryParse(dateField);
    } catch (_) {}
    return null;
  }

  Stream<List<QuerySnapshot>> _zipStreams(List<Stream<QuerySnapshot>> streams) {
    final controller = StreamController<List<QuerySnapshot>>();
    final List<QuerySnapshot?> latestResults = List.filled(streams.length, null);
    final List<StreamSubscription> subscriptions = [];

    void update() {
      if (latestResults.every((res) => res != null)) {
        controller.add(latestResults.cast<QuerySnapshot>());
      }
    }

    for (int i = 0; i < streams.length; i++) {
      subscriptions.add(streams[i].listen(
        (data) {
          latestResults[i] = data;
          update();
        },
        onError: (err) {
          debugPrint("Stream Error in collection index $i: $err");
          // Optionally send a partial result or empty snapshot if one collection fails
          latestResults[i] = null;
        },
      ));
    }

    controller.onCancel = () {
      for (var sub in subscriptions) {
        sub.cancel();
      }
    };

    return controller.stream;
  }
}
