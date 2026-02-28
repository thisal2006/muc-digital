import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;


class CrematoriumDocumentUploadScreen extends StatefulWidget {
  const CrematoriumDocumentUploadScreen({super.key});

  @override
  State<CrematoriumDocumentUploadScreen> createState() => _CrematoriumDocumentUploadScreenState();
}

class _CrematoriumDocumentUploadScreenState extends State<CrematoriumDocumentUploadScreen> {
  File? _image;
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }
  Future<void> uploadImage() async {
    if (_image == null) return;

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

      // Success
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Uploaded successfully! URL: $downloadUrl'),
          backgroundColor: Colors.green,
        ),
      );

      // TODO: Save to Firestore (date, time, eligibility, image URL)
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Documents')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload required documents (e.g. Death Certificate, NIC)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            ElevatedButton(
              onPressed: _image != null ? uploadImage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _image != null ? Colors.blue[800] : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Upload & Proceed to Payment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

