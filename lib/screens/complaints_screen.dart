// complaints_screen.dart
// This screen allows citizens to report municipal issues like illegal dumping.
// It features a tabbed interface for creating new reports and viewing past history.

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

/// Main screen for the Complaints feature.
/// Uses a DefaultTabController to switch between 'New Report' and 'History'.
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
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Complaints Center",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Help keep the city clean",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "New Report"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NewComplaintForm(), // Form to submit a new report
            MyComplaintsList(), // Real-time list of user's past reports
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// NEW REPORT TAB (Focus: Illegal Dumping)
////////////////////////////////////////////////////////////

class NewComplaintForm extends StatefulWidget {
  const NewComplaintForm({super.key});

  @override
  State<NewComplaintForm> createState() => _NewComplaintFormState();
}

class _NewComplaintFormState extends State<NewComplaintForm> {
  // Controller for user input description
  final TextEditingController descriptionController = TextEditingController();
  // Utility to handle camera and gallery access
  final ImagePicker picker = ImagePicker();

  File? imageFile;      // Stores the captured/selected image
  bool isUploading = false; // Tracks submission progress
  double uploadProgress = 0; // Stores Firebase Storage upload percentage

  //--------------------------------------------------
  // PICK IMAGE: Captures a photo using the device camera
  //--------------------------------------------------
  Future<void> pickImage() async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Compressing image to reduce upload time
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
  // GET LOCATION: Requests GPS coordinates for the report
  //--------------------------------------------------
  Future<Position> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied.");
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
    );
  }

  //--------------------------------------------------
  // SUBMIT REPORT: Coordinates upload and database entry
  //--------------------------------------------------
  Future<void> submitReport() async {
    final description = descriptionController.text.trim();

    // Validation: Image and text are mandatory
    if (imageFile == null || description.isEmpty) {
      _showError("Photo and description required");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError("User not logged in");
      return;
    }

    setState(() {
      isUploading = true;
      uploadProgress = 0;
    });

    try {
      // 1. Get user's current GPS location
      final position = await _getLocation();

      // 2. UPLOAD IMAGE TO FIREBASE STORAGE
      final fileName = "dump_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = FirebaseStorage.instance.ref().child("complaints/$fileName");

      UploadTask uploadTask = ref.putFile(imageFile!);

      // Listen to bytes transferred to update progress bar
      uploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / event.totalBytes;
        setState(() {
          uploadProgress = progress;
        });
      });

      TaskSnapshot snapshot = await uploadTask.timeout(const Duration(seconds: 30));
      final imageUrl = await snapshot.ref.getDownloadURL();

      // 3. SAVE METADATA TO CLOUD FIRESTORE
      await FirebaseFirestore.instance.collection("complaints").add({
        "userId": user.uid,
        "description": description,
        "imageUrl": imageUrl,
        "status": "Pending",
        "category": "Illegal Dumping",
        "priority": "normal",
        "reportedBy": "citizen",
        "createdAt": FieldValue.serverTimestamp(),
        "location": GeoPoint(position.latitude, position.longitude),
      });

      // 4. RESET FORM ON SUCCESS
      if (!mounted) return;
      setState(() => isUploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Report submitted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to History tab
      DefaultTabController.of(context).animateTo(1);

    } catch (e) {
      setState(() => isUploading = false);
      _showError("Submission failed: $e");
    }
  }

  // Helper to show floating error snacks
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            "Report Illegal Dumping",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // IMAGE ATTACHMENT AREA
          GestureDetector(
            onTap: isUploading ? null : pickImage,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: imageFile == null
                  ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 50, color: Colors.lightGreen),
                  SizedBox(height: 8),
                  Text("Tap to capture photo"),
                ],
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(imageFile!, fit: BoxFit.cover),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // DESCRIPTION INPUT
          TextField(
            controller: descriptionController,
            maxLines: 4,
            maxLength: 300,
            decoration: InputDecoration(
              labelText: "Describe issue",
              hintText: "Example: garbage dumped near road",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 20),

          // UPLOAD PROGRESS BAR
          if (isUploading)
            LinearProgressIndicator(
              value: uploadProgress,
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),

          const SizedBox(height: 20),

          // SUBMIT BUTTON
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isUploading ? null : submitReport,
              child: isUploading
                  ? Text("${(uploadProgress * 100).toStringAsFixed(0)}%")
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

////////////////////////////////////////////////////////////
/// HISTORY TAB: Shows real-time stream of reports
////////////////////////////////////////////////////////////

class MyComplaintsList extends StatelessWidget {
  const MyComplaintsList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please login to view reports"));
    }

    return StreamBuilder<QuerySnapshot>(
      // Listens to Firestore changes for the current user's reports
      stream: FirebaseFirestore.instance
          .collection('complaints')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.report_problem_outlined, size: 60, color: Colors.grey),
                SizedBox(height: 12),
                Text("No reports submitted yet", style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            
            // Allows user to delete their own pending reports
            return Dismissible(
                key: Key(docs[index].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  await FirebaseFirestore.instance.collection('complaints').doc(docs[index].id).delete();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report deleted")));
                },
                child: _ComplaintHistoryCard(
                  category: "Illegal Dumping",
                  description: data['description'] ?? '',
                  status: data['status'] ?? '',
                  date: data['createdAt'] != null
                      ? DateFormat('dd MMM yyyy • hh:mm a').format((data['createdAt'] as Timestamp).toDate())
                      : "Recent",
                  imageUrl: data['imageUrl'],
                ),
            );
          },
        );
      },
    );
  }
}

////////////////////////////////////////////////////////////
/// HISTORY CARD UI: Displays summary of a single report
////////////////////////////////////////////////////////////

class _ComplaintHistoryCard extends StatelessWidget {
  final String category;
  final String description;
  final String status;
  final String date;
  final String? imageUrl;

  const _ComplaintHistoryCard({
    required this.category,
    required this.description,
    required this.status,
    required this.date,
    this.imageUrl,
  });

  // Maps backend status to human-readable labels
  String get normalizedStatus {
    final value = status.trim().toLowerCase();
    if (value == 'resolved' || value == 'completed') return 'Resolved';
    if (value == 'in progress' || value == 'in_progress') return 'In Progress';
    return 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    // Assign color based on the report's progress
    switch (normalizedStatus) {
      case 'Resolved': statusColor = Colors.green; break;
      case 'In Progress': statusColor = Colors.orange; break;
      default: statusColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withAlpha(26),
              child: Icon(Icons.report_problem_outlined, color: statusColor),
            ),
            title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(date),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                normalizedStatus,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          // Network image with loading placeholder
          if (imageUrl != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
