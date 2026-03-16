// complaints_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

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

////////////////////////////////////////////////////////////
/// NEW REPORT TAB (Illegal Dumping)
////////////////////////////////////////////////////////////

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
  // SUBMIT REPORT
  //--------------------------------------------------

  Future<void> submitReport() async {

    final description = descriptionController.text.trim();

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

      final position = await _getLocation();

      //----------------------------------
      // UPLOAD IMAGE
      //----------------------------------

      final fileName =
          "dump_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final ref = FirebaseStorage.instance
          .ref()
          .child("illegal_dumps/$fileName");

      UploadTask uploadTask = ref.putFile(imageFile!);

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
      // SAVE TO FIRESTORE
      //----------------------------------

      await FirebaseFirestore.instance
          .collection("illegal_dumps")
          .add({

        "userId": user.uid,

        "description": description,

        "imageUrl": imageUrl,

        "status": "pending",

        "priority": "normal",

        "reportedBy": "citizen",

        "createdAt": FieldValue.serverTimestamp(),

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Report submitted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      DefaultTabController.of(context).animateTo(1);

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
    ScaffoldMessenger.of(context).showSnackBar(
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
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
                border: Border.all(
                  color: Colors.grey.shade400,
                ),
              ),
              child: imageFile == null
                  ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 50),
                  SizedBox(height: 8),
                  Text("Tap to capture photo"),
                ],
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  imageFile!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: descriptionController,
            maxLines: 4,
            maxLength: 300,
            decoration: InputDecoration(
              labelText: "Describe issue",
              hintText: "Example: garbage dumped near road",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // you can add more style properties here (padding, elevation, etc.)
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
/// HISTORY TAB
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

      stream: FirebaseFirestore.instance
          .collection('illegal_dumps')
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
                Icon(Icons.report_problem_outlined,
                    size: 60,
                    color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  "No reports submitted yet",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(

          padding: const EdgeInsets.all(16),

          itemCount: docs.length,

          itemBuilder: (context, index) {

            final data =
            docs[index].data() as Map<String, dynamic>;
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
                  await FirebaseFirestore.instance
                      .collection('illegal_dumps')
                      .doc(docs[index].id)
                      .delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Report deleted")),
                  );
                },
                child: _ComplaintHistoryCard(

              category: "Illegal Dumping",
              description: data['description'] ?? '',
              status: data['status'] ?? '',
              date: data['createdAt'] != null
                  ? DateFormat('dd MMM yyyy • hh:mm a')
                  .format((data['createdAt'] as Timestamp).toDate())
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
/// HISTORY CARD
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

  @override
  Widget build(BuildContext context) {

    Color statusColor;

    switch (status) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withAlpha(26),
              child: Icon(
                Icons.report_problem_outlined,
                color: statusColor,
              ),
            ),

            title: Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: Text(date),

            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),

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
