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
                  SizedBox(height: 16),
                  const Text('No bookings yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Your future bookings will appear here', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index];
              
              DateTime? bookingDate;
              try {
                final dynamic dateField = data['date'];
                if (dateField is Timestamp) {
                  bookingDate = dateField.toDate();
                } else if (dateField is String) {
                  bookingDate = DateTime.tryParse(dateField);
                }
                
                // Fallback to timestamp if date is missing or couldn't be parsed
                if (bookingDate == null) {
                  if (data['timestamp'] is Timestamp) {
                    bookingDate = (data['timestamp'] as Timestamp).toDate();
                  } else if (data['createdAt'] is Timestamp) {
                    bookingDate = (data['createdAt'] as Timestamp).toDate();
                  }
                }
              } catch (e) {
                debugPrint("Error parsing date: $e");
              }

              final String status = data['status'] ?? 'Pending';
              Color statusColor;
              switch (status.toLowerCase()) {
                case 'confirmed':
                case 'completed':
                case 'paid':
                case 'approved':
                  statusColor = Colors.green;
                  break;
                case 'cancelled':
                case 'rejected':
                  statusColor = Colors.red;
                  break;
                case 'pending':
                case 'approval pending':
                default:
                  statusColor = Colors.orange;
              }

              // Identify Booking Type for better UI
              String bookingTitle = data['property_name'] ?? data['type'] ?? data['category'] ?? 'General Booking';
              IconData categoryIcon = Icons.book_online;
              String sourceLabel = "Other";
              
              if (data['source_collection'] == 'property_bookings') {
                categoryIcon = Icons.apartment;
                sourceLabel = "Property";
              } else if (data['source_collection'] == 'crematorium_bookings') {
                categoryIcon = Icons.church;
                sourceLabel = "Crematorium";
                bookingTitle = "Crematorium Slot";
              } else if (data['source_collection'] == 'bookings') {
                categoryIcon = Icons.directions_car;
                sourceLabel = "Vehicle";
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
                                Icon(categoryIcon, color: const Color(0xFF1B5E20), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    bookingTitle,
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
                          const Icon(Icons.event, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            bookingDate != null
                                ? DateFormat('EEEE, dd MMM yyyy').format(bookingDate)
                                : 'Date not specified',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            data['slot'] ?? data['timeSlot'] ?? data['time'] ?? 'Time not specified',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.label_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            "Type: $sourceLabel",
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          Text(
                            'LKR ${data['price'] ?? data['amount'] ?? '0.00'}',
                            style: const TextStyle(
                              fontSize: 17, 
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
    
    // 1. Property Bookings Stream
    final propertyStream = FirebaseFirestore.instance
        .collection('property_bookings')
        .where('user_id', isEqualTo: userId)
        .snapshots();

    // 2. Crematorium Bookings Stream
    final crematoriumStream = FirebaseFirestore.instance
        .collection('crematorium_bookings')
        .where('userId', isEqualTo: userId)
        .snapshots();

    // 3. Vehicle Bookings Stream (Generic 'bookings' collection)
    final vehicleStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots();

    // Merge streams using a helper that doesn't require extra packages
    return _zipStreams([propertyStream, crematoriumStream, vehicleStream]).map((snapshots) {
      final List<Map<String, dynamic>> allBookings = [];

      final collections = ['property_bookings', 'crematorium_bookings', 'bookings'];

      for (int i = 0; i < snapshots.length; i++) {
        for (var doc in snapshots[i].docs) {
          var data = doc.data() as Map<String, dynamic>;
          data['source_collection'] = collections[i];
          data['id'] = doc.id;
          allBookings.add(data);
        }
      }

      // Sort combined list by date (newest first)
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
      
      final dynamic dateField = data['date'];
      if (dateField is Timestamp) return dateField.toDate();
      if (dateField is String) return DateTime.tryParse(dateField);
    } catch (_) {}
    return null;
  }

  // Helper to zip multiple streams manually
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
        onError: controller.addError,
        onDone: () {
          // If any stream is done, we could potentially close, but snapshots don't usually close
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
