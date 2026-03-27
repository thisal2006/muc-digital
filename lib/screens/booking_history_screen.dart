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
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 8),
                    const Text('Checking for your bookings across services...', 
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No bookings found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
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
              final source = data['source_collection'] as String?;
              
              String title = 'General Booking';
              String amount = '0.00';
              String status = data['status'] ?? 'Pending';
              IconData categoryIcon = Icons.book_online;
              String dateInfo = 'Date not specified';
              String timeInfo = '';

              // Customize based on collection source
              if (source == 'property_bookings') {
                title = data['property_name'] ?? 'Property Booking';
                amount = data['price'] ?? '0.00';
                dateInfo = data['date'] ?? 'Date not specified';
                timeInfo = data['slot'] ?? '';
                categoryIcon = Icons.apartment;
              } else if (source == 'crematorium_bookings') {
                title = 'Crematorium Slot';
                amount = 'Council Fee';
                categoryIcon = Icons.church;
                final dynamic d = data['date'];
                if (d is Timestamp) {
                  dateInfo = DateFormat('dd MMM yyyy').format(d.toDate());
                } else if (d != null) {
                  dateInfo = d.toString();
                }
                timeInfo = data['timeSlot'] ?? '';
              } else if (source == 'bookings') {
                // Vehicle bookings
                categoryIcon = Icons.directions_car;
                final vehicle = data['vehicleDetails'] ?? data['vehicle']; 
                if (vehicle != null && vehicle is Map) {
                  title = "${vehicle['brand'] ?? ''} ${vehicle['model'] ?? ''}".trim();
                  if (title.isEmpty) title = "Vehicle Booking";
                } else {
                  title = data['bookingType'] ?? "Vehicle Booking";
                }
                final totalPrice = data['totalAmount'] ?? data['totalPrice'] ?? data['amount'] ?? '0.00';
                amount = totalPrice.toString();
                
                // Handle startDate if it's a Timestamp or String
                dynamic start = data['startDate'];
                dynamic end = data['endDate'];
                String startStr = "";
                String endStr = "";
                
                if (start is Timestamp) {
                  startStr = DateFormat('yyyy-MM-dd').format(start.toDate());
                } else {
                  startStr = start?.toString() ?? "";
                }
                
                if (end is Timestamp) {
                  endStr = DateFormat('yyyy-MM-dd').format(end.toDate());
                } else {
                  endStr = end?.toString() ?? "";
                }
                
                dateInfo = "$startStr ${endStr.isNotEmpty && endStr != startStr ? '- $endStr' : ''}".trim();
                if (dateInfo.isEmpty) dateInfo = "Date not specified";
              }

              // Unified Status Color mapping
              Color statusColor;
              final normalizedStatus = status.toLowerCase();
              if (['confirmed', 'completed', 'paid', 'approved', 'approved, payment pending'].contains(normalizedStatus)) {
                statusColor = Colors.green;
              } else if (['cancelled', 'rejected', 'failed'].contains(normalizedStatus)) {
                statusColor = Colors.red;
              } else {
                statusColor = Colors.orange;
              }

              return Card(
                elevation: 2,
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
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B5E20).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(categoryIcon, color: const Color(0xFF1B5E20), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: statusColor.withOpacity(0.5)),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(dateInfo, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        ],
                      ),
                      if (timeInfo.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(timeInfo, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            source?.replaceAll('_', ' ').toUpperCase() ?? 'BOOKING',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          Text(
                            amount.contains('LKR') ? amount : 'LKR $amount',
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

  Stream<List<Map<String, dynamic>>> _getAllBookingsStream() {
    final userId = user?.uid;
    
    final propertyStream = FirebaseFirestore.instance
        .collection('property_bookings')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map((d) => {...d.data(), 'source_collection': 'property_bookings', 'id': d.id}).toList())
        .handleError((e) => <Map<String, dynamic>>[]);

    final crematoriumStream = FirebaseFirestore.instance
        .collection('crematorium_bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map((d) => {...d.data(), 'source_collection': 'crematorium_bookings', 'id': d.id}).toList())
        .handleError((e) => <Map<String, dynamic>>[]);

    // Vehicle stream should check both user_id and userId for safety during migration
    final vehicleStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map((d) => {...d.data(), 'source_collection': 'bookings', 'id': d.id}).toList())
        .handleError((e) => <Map<String, dynamic>>[]);

    return _combineLatest([propertyStream, crematoriumStream, vehicleStream]);
  }

  Stream<List<Map<String, dynamic>>> _combineLatest(List<Stream<List<Map<String, dynamic>>>> streams) {
    final controller = StreamController<List<Map<String, dynamic>>>();
    final List<List<Map<String, dynamic>>> latestResults = List.generate(streams.length, (_) => []);
    final List<StreamSubscription> subscriptions = [];

    void update() {
      final List<Map<String, dynamic>> all = latestResults.expand((list) => list).toList();
      all.sort((a, b) {
        final dateA = _getDateTime(a);
        final dateB = _getDateTime(b);
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });
      if (!controller.isClosed) {
        controller.add(all);
      }
    }

    for (int i = 0; i < streams.length; i++) {
      subscriptions.add(streams[i].listen(
        (data) {
          latestResults[i] = data;
          update();
        },
        onError: (err) {
          latestResults[i] = [];
          update();
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

  DateTime? _getDateTime(Map<String, dynamic> data) {
    try {
      if (data['timestamp'] is Timestamp) return (data['timestamp'] as Timestamp).toDate();
      if (data['createdAt'] is Timestamp) return (data['createdAt'] as Timestamp).toDate();
      if (data['createdAt'] is String) return DateTime.tryParse(data['createdAt']);
      
      final dynamic dateField = data['date'];
      if (dateField is Timestamp) return dateField.toDate();
      if (dateField is String) return DateTime.tryParse(dateField);
      
      final dynamic startDateField = data['startDate'];
      if (startDateField is Timestamp) return startDateField.toDate();
      if (startDateField is String) return DateTime.tryParse(startDateField);
    } catch (_) {}
    return null;
  }
}
