import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';


class CrematoriumDocumentUploadScreen extends StatefulWidget {
  const CrematoriumDocumentUploadScreen({super.key});

  @override
  State<CrematoriumDocumentUploadScreen> createState() => _CrematoriumDocumentUploadScreenState();
}

class _CrematoriumDocumentUploadScreenState extends State<CrematoriumDocumentUploadScreen> {
  File? _image;
  final picker = ImagePicker();
  bool _isUploading = false;

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> uploadAndSaveBooking() async {
    if (_image == null) return;

    setState(() => _isUploading = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Uploading document...')),
    );

    try {
      // Create unique filename
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(_image!.path)}';

      // Upload to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child('crematorium_documents/$fileName');
      await ref.putFile(_image!);

      // Get download URL
      String downloadUrl = await ref.getDownloadURL();

      // Save booking to Firestore
      await FirebaseFirestore.instance.collection('crematorium_bookings').add({
        'date': Timestamp.fromDate(DateTime.now()), // TODO: Pass real selected date
        'timeSlot': 'Morning (example)', // TODO: Pass real selected time slot
        'isResident': true, // TODO: Pass from eligibility
        'relation': 'Immediate family', // TODO: Pass from eligibility
        'documentUrl': downloadUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'userId': 'current_user_id', // TODO: Get from FirebaseAuth.instance.currentUser?.uid
      });

      // Success
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Booking saved successfully! Document uploaded.'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() => _isUploading = false);
      // TODO: Navigate to payment screen
      // Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen()));

    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Upload Documents'),
          backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload required documents (e.g. Death Certificate, NIC)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold , color: Colors.black87),
            ),
            const SizedBox(height: 24),

            if (_image != null)
              Image.file(_image!, height: 200, fit: BoxFit.cover)
            else
              Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: Text('No image selected')),
              ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick Image from Gallery'),
              onPressed: pickImage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),

            const SizedBox(height: 32),

            // Image Preview
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: _image != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_image!, fit: BoxFit.cover),
              )
                  : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No image selected',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Pick Image Button
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
