import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class IllegalDumpingScreen extends StatefulWidget {
  const IllegalDumpingScreen({super.key});

  @override
  State<IllegalDumpingScreen> createState() => _IllegalDumpingScreenState();
}

class _IllegalDumpingScreenState extends State<IllegalDumpingScreen> {

  final TextEditingController descriptionController =
  TextEditingController();

  File? imageFile;
  bool isUploading = false;

  //--------------------------------------------------
  // PICK IMAGE
  //--------------------------------------------------

  Future<void> pickImage() async {

    final picked = await ImagePicker()
        .pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  //--------------------------------------------------
  // GET LOCATION
  //--------------------------------------------------

  Future<Position> _getLocation() async {

    LocationPermission permission =
    await Geolocator.requestPermission();

    return await Geolocator.getCurrentPosition(
      locationSettings:
      const LocationSettings(accuracy: LocationAccuracy.best),
    );
  }

  //--------------------------------------------------
  // SUBMIT REPORT
  //--------------------------------------------------

  Future<void> submitReport() async {

    if (imageFile == null ||
        descriptionController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Photo and description required"),
        ),
      );
      return;
    }

    setState(() => isUploading = true);

    try {

      //----------------------------------
      // LOCATION
      //----------------------------------

      final position = await _getLocation();

      //----------------------------------
      // UPLOAD IMAGE
      //----------------------------------

      final fileName =
          "dump_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final ref = FirebaseStorage.instance
          .ref()
          .child("illegal_dumps/$fileName");

      await ref.putFile(imageFile!);

      final imageUrl = await ref.getDownloadURL();

      //----------------------------------
      // SAVE TO FIRESTORE
      //----------------------------------

      await FirebaseFirestore.instance
          .collection("illegal_dumps")
          .add({
        "description": descriptionController.text,
        "imageUrl": imageUrl,
        "lat": position.latitude,
        "lng": position.longitude,
        "status": "pending",
        "createdAt": Timestamp.now(),
      });

      //----------------------------------
      // SUCCESS
      //----------------------------------

      setState(() => isUploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Report submitted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      setState(() => isUploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  //--------------------------------------------------
  // UI
  //--------------------------------------------------

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Illegal Dumping"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            //----------------------------------
            // IMAGE PREVIEW
            //----------------------------------

            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: imageFile == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(imageFile!,
                      fit: BoxFit.cover),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //----------------------------------
            // DESCRIPTION
            //----------------------------------

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Describe the issue",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            //----------------------------------
            // BUTTON
            //----------------------------------

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                isUploading ? null : submitReport,
                child: isUploading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text("Submit Report"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
