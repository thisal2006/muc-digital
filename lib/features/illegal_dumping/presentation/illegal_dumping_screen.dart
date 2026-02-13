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

  final ImagePicker picker = ImagePicker();

  File? imageFile;

  bool isUploading = false;
  double uploadProgress = 0;

  //--------------------------------------------------
  // PICK IMAGE
  //--------------------------------------------------

  Future<void> pickImage() async {

    try {

      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (picked != null) {
        setState(() {
          imageFile = File(picked.path);
        });
      }

    } catch (e) {
      _showError("Camera error: $e");
    }
  }

  //--------------------------------------------------
  // LOCATION
  //--------------------------------------------------

  Future<Position> _getLocation() async {

    bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception("Location services disabled.");
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
      await Geolocator.requestPermission();
    }

    if (permission ==
        LocationPermission.deniedForever) {
      throw Exception(
          "Location permission permanently denied.");
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
    );
  }

  //--------------------------------------------------
  // SUBMIT REPORT
  //--------------------------------------------------

  Future<void> submitReport() async {

    final description =
    descriptionController.text.trim();

    if (imageFile == null || description.isEmpty) {
      _showError("Photo and description required");
      return;
    }

    setState(() {
      isUploading = true;
      uploadProgress = 0;
    });

    try {

      //----------------------------------
      // GET LOCATION
      //----------------------------------

      final position = await _getLocation();

      //----------------------------------
      // STORAGE UPLOAD (TRACKED)
      //----------------------------------

      final fileName =
          "dump_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final ref = FirebaseStorage.instance
          .ref()
          .child("illegal_dumps/$fileName");

      UploadTask uploadTask =
      ref.putFile(imageFile!);

      /// 🔥 TRACK PROGRESS
      uploadTask.snapshotEvents.listen((event) {

        final progress =
            event.bytesTransferred /
                event.totalBytes;

        setState(() {
          uploadProgress = progress;
        });
      });

      /// 🔥 FORCE TIMEOUT (NO MORE INFINITE SPINNER)
      TaskSnapshot snapshot =
      await uploadTask.timeout(
        const Duration(seconds: 30),
      );

      final imageUrl =
      await snapshot.ref.getDownloadURL();

      //----------------------------------
      // FIRESTORE WRITE
      //----------------------------------

      await FirebaseFirestore.instance
          .collection("illegal_dumps")
          .add({

        "description": description,
        "imageUrl": imageUrl,

        // ⭐ USE GEOPPOINT (VERY IMPORTANT FOR FUTURE MAP QUERIES)
        "location": GeoPoint(
          position.latitude,
          position.longitude,
        ),

        "status": "pending",
        "priority": "normal",
        "reportedBy": "citizen",

        "createdAt":
        FieldValue.serverTimestamp(),
      });

      //----------------------------------
      // SUCCESS
      //----------------------------------

      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
          Text("Report submitted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      setState(() {
        isUploading = false;
      });

      _showError("Upload failed: $e");
    }
  }

  //--------------------------------------------------
  // ERROR HELPER
  //--------------------------------------------------

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  //--------------------------------------------------
  // UI
  //--------------------------------------------------

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
        const Text("Report Illegal Dumping"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            //----------------------------------
            // IMAGE
            //----------------------------------

            GestureDetector(
              onTap:
              isUploading ? null : pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: imageFile == null
                    ? const Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt,
                        size: 50),
                    SizedBox(height: 8),
                    Text(
                        "Tap to capture photo"),
                  ],
                )
                    : ClipRRect(
                  borderRadius:
                  BorderRadius.circular(12),
                  child: Image.file(
                    imageFile!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //----------------------------------
            // DESCRIPTION
            //----------------------------------

            TextField(
              controller:
              descriptionController,
              maxLines: 4,
              decoration:
              const InputDecoration(
                labelText:
                "Describe the issue",
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            //----------------------------------
            // PROGRESS BAR
            //----------------------------------

            if (isUploading)
              LinearProgressIndicator(
                value: uploadProgress,
              ),

            const SizedBox(height: 20),

            //----------------------------------
            // BUTTON
            //----------------------------------

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                isUploading
                    ? null
                    : submitReport,
                child: isUploading
                    ? Text(
                  "${(uploadProgress * 100).toStringAsFixed(0)}%",
                )
                    : const Text(
                  "Submit Report",
                  style:
                  TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}
