/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Remove the path import if not needed, or add path to pubspec.yaml
// import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'crematorium_booking_data.dart';  // Model for passed data
// Update this import path to match your actual payment screen location
import '../property/screens/payment_screen.dart';  // Adjust path as needed

class CrematoriumDocumentUploadScreen extends StatefulWidget {
  final CrematoriumBookingData bookingData;  // Receives real data from previous screens

  const CrematoriumDocumentUploadScreen({
    super.key,
    required this.bookingData,
  });

  @override
  State<CrematoriumDocumentUploadScreen> createState() => _CrematoriumDocumentUploadScreenState();
}

class _CrematoriumDocumentUploadScreenState extends State<CrematoriumDocumentUploadScreen> {
  File? _image;
  final picker = ImagePicker();
  bool _isUploading = false;

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (mounted) {
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        }
      });
    }
  }

  String _getFileName(String path) {
    // Manual implementation instead of using path.basename
    return path.split('/').last;
  }

  Future<void> uploadAndSaveBooking() async {
    if (_image == null) return;

    setState(() => _isUploading = true);

    // Store context reference before async gap
    final currentContext = context;
    final scaffoldMessenger = ScaffoldMessenger.of(currentContext);

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Uploading document...')),
    );

    try {
      // Unique filename - manual basename implementation
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${_getFileName(_image!.path)}';

      // Upload to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child('crematorium_documents/$fileName');
      await ref.putFile(_image!);

      // Get download URL
      String downloadUrl = await ref.getDownloadURL();

      // Save real booking data to Firestore
      await FirebaseFirestore.instance.collection('crematorium_bookings').add({
        'date': widget.bookingData.selectedDate != null
            ? Timestamp.fromDate(widget.bookingData.selectedDate!)
            : FieldValue.serverTimestamp(),
        'timeSlot': widget.bookingData.timeSlot ?? 'Unknown',
        'isResident': widget.bookingData.isResident,
        'relation': widget.bookingData.relation ?? 'Unknown',
        'documentUrl': downloadUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
      });

      // Check if widget is still mounted before using context
      if (!mounted) return;

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Booking saved successfully! Document uploaded.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to payment screen
      Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder: (context) => const PaymentScreen(),
        ),
      );

      if (mounted) {
        setState(() => _isUploading = false);
      }

    } catch (e) {
      if (mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Documents'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Upload required documents',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '(e.g. Death Certificate, NIC)',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),

            // Image Preview Card
            Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 240),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_image!, fit: BoxFit.cover),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No image selected',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Pick Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text('Pick Image from Gallery'),
                onPressed: pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Upload Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _image != null && !_isUploading ? uploadAndSaveBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _image != null ? Colors.blue[800] : Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: _image != null ? 6 : 0,
                ),
                child: _isUploading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : const Text(
                  'Upload & Proceed to Payment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

*/