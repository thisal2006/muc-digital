import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

            ElevatedButton(
              onPressed: _image != null
                  ? () {
                // Simulate upload success (replace later with real Firebase upload)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Documents uploaded successfully! Proceeding to payment...'),
                    backgroundColor: Colors.green,
                  ),
                );

                // TODO: Navigate to payment screen (add later)
                // Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen()));
              }
                  : null,  // Button disabled (grey) if no image selected
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