import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String? id;
  final String userId;
  final String propertyName;
  final String date;
  final String slot;
  final String price;
  final String purpose;
  final String crowdSize;
  final String status;
  final Timestamp timestamp;

  Booking({
    this.id,
    required this.userId,
    required this.propertyName,
    required this.date,
    required this.slot,
    required this.price,
    required this.purpose,
    required this.crowdSize,
    this.status = 'Approval Pending',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'property_name': propertyName,
      'date': date,
      'slot': slot,
      'price': price,
      'purpose': purpose,
      'crowd_size': crowdSize,
      'status': status,
      'timestamp': timestamp,
    };
  }
}