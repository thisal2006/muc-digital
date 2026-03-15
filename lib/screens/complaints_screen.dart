// complaints_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class ComplaintsScreen extends StatefulWidget {
  final int initialTabIndex;
  const ComplaintsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF8),
        appBar: AppBar(
          title: const Text(
            "Complaints Center",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: "New Report"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NewComplaintForm(),
            MyComplaintsList(),
          ],
        ),
      ),
    );
  }
}



class NewComplaintForm extends StatefulWidget {
  const NewComplaintForm({super.key});

  @override
  State<NewComplaintForm> createState() => _NewComplaintFormState();
}

class _NewComplaintFormState extends State<NewComplaintForm> {

  final TextEditingController descriptionController = TextEditingController();

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
  // GET LOCATION
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

      final user = FirebaseAuth.instance.currentUser;

      final position = await _getLocation();

      //----------------------------------
      // UPLOAD IMAGE
      //----------------------------------

      final fileName =
          "dump_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final ref = FirebaseStorage.instance
          .ref()
          .child("illegal_dumps/$fileName");

      UploadTask uploadTask =
      ref.putFile(imageFile!);

      uploadTask.snapshotEvents.listen((event) {

        final progress =
            event.bytesTransferred /
                event.totalBytes;

        setState(() {
          uploadProgress = progress;
        });
      });

      TaskSnapshot snapshot =
      await uploadTask.timeout(
        const Duration(seconds: 30),
      );

      final imageUrl =
      await snapshot.ref.getDownloadURL();

      //----------------------------------
      // FIRESTORE SAVE
      //----------------------------------

      await FirebaseFirestore.instance
          .collection("complaints")
          .add({

        "userId": user?.uid,

        "category": "Illegal Dumping",

        "description": description,

        "imageUrl": imageUrl,

        "status": "Pending",

        "createdAt":
        FieldValue.serverTimestamp(),

        "location": GeoPoint(
          position.latitude,
          position.longitude,
        ),
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

      DefaultTabController.of(context)
          .animateTo(1);

    } catch (e) {

      setState(() {
        isUploading = false;
      });

      _showError("Upload failed: $e");
    }
  }

  //--------------------------------------------------
  // ERROR
  //--------------------------------------------------

  void _showError(String message) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  //--------------------------------------------------
  // UI
  //--------------------------------------------------

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [

          const Text(
            "Report Illegal Dumping",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          GestureDetector(
            onTap: isUploading ? null : pickImage,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(12),
                color: Colors.grey.shade100,
                border: Border.all(
                  color: Colors.grey.shade400,
                ),
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
                BorderRadius.circular(
                    12),
                child: Image.file(
                  imageFile!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller:
            descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Describe issue",
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          if (isUploading)
            LinearProgressIndicator(
              value: uploadProgress,
            ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
              isUploading ? null : submitReport,
              child: isUploading
                  ? Text(
                  "${(uploadProgress * 100).toStringAsFixed(0)}%")
                  : const Text("Submit Report"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}

