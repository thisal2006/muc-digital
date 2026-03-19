// illegal_dumping_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class IllegalDumpingScreen extends StatefulWidget {
  const IllegalDumpingScreen({super.key});

  @override
  State<IllegalDumpingScreen> createState() =>
      _IllegalDumpingScreenState();
}

class _IllegalDumpingScreenState extends State<IllegalDumpingScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF8),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Illegal Dumping",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Help keep the city clean",
                  style: TextStyle(fontSize: 13)),
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
            _IllegalForm(),
            _IllegalHistory(),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// FORM
////////////////////////////////////////////////////////////

class _IllegalForm extends StatefulWidget {
  const _IllegalForm();

  @override
  State<_IllegalForm> createState() => _IllegalFormState();
}

class _IllegalFormState extends State<_IllegalForm> {
  final TextEditingController descriptionController =
  TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? imageFile;
  bool isUploading = false;
  double uploadProgress = 0;

  Future<void> pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<Position> _getLocation() async {
    await Geolocator.requestPermission();
    return await Geolocator.getCurrentPosition();
  }

  Future<void> submitReport() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showError("User not logged in");
      return;
    }

    if (imageFile == null ||
        descriptionController.text.isEmpty) {
      _showError("Photo and description required");
      return;
    }

    setState(() {
      isUploading = true;
      uploadProgress = 0;
    });

    try {
      final position = await _getLocation();

      final fileName =
          "dump_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final ref = FirebaseStorage.instance
          .ref("illegal_dumps/$fileName");

      final uploadTask = ref.putFile(imageFile!);

      uploadTask.snapshotEvents.listen((event) {
        setState(() {
          uploadProgress =
              event.bytesTransferred / event.totalBytes;
        });
      });

      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("illegal_dumps")
          .add({
        "userId": user.uid,
        "description": descriptionController.text.trim(),
        "imageUrl": imageUrl,
        "status": "Pending",
        "priority": "normal",
        "reportedBy": "citizen",
        "createdAt": FieldValue.serverTimestamp(),
        "location": GeoPoint(
          position.latitude,
          position.longitude,
        ),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Report submitted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      DefaultTabController.of(context).animateTo(1);
    } catch (e) {
      _showError("Upload failed: $e");
    }

    setState(() => isUploading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GestureDetector(
            onTap: pickImage,
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
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo,
                      size: 50, color: Colors.green),
                  SizedBox(height: 8),
                  Text("Tap to capture photo"),
                ],
              )
                  : ClipRRect(
                borderRadius:
                BorderRadius.circular(12),
                child: Image.file(imageFile!,
                    fit: BoxFit.cover),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (isUploading)
            LinearProgressIndicator(
              value: uploadProgress,
              minHeight: 6,
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF2E7D32),
              ),
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
}

////////////////////////////////////////////////////////////
/// HISTORY WITH DELETE
////////////////////////////////////////////////////////////

class _IllegalHistory extends StatelessWidget {
  const _IllegalHistory();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Login required"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('illegal_dumps')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text("No reports submitted yet"),
          );
        }

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
                padding:
                const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius:
                  BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete,
                    color: Colors.white),
              ),
              onDismissed: (direction) async {
                await FirebaseFirestore.instance
                    .collection('illegal_dumps')
                    .doc(docs[index].id)
                    .delete();

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                      content: Text("Report deleted")),
                );
              },
              child: _HistoryCard(
                description:
                data['description'] ?? '',
                status: data['status'] ?? '',
                date: data['createdAt'] != null
                    ? DateFormat(
                    'dd MMM yyyy • hh:mm a')
                    .format((data['createdAt']
                as Timestamp)
                    .toDate())
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
/// CARD
////////////////////////////////////////////////////////////

class _HistoryCard extends StatelessWidget {
  final String description;
  final String status;
  final String date;
  final String? imageUrl;

  const _HistoryCard({
    required this.description,
    required this.status,
    required this.date,
    this.imageUrl,
  });

  String get normalizedStatus {
    final value = status.trim().toLowerCase();
    if (value == 'Resolved') return 'Resolved';
    if (value == 'In Progress') return 'In Progress';
    return 'Pending';
  }

  Color get statusBackgroundColor {
    switch (normalizedStatus) {
      case 'Resolved':
        return const Color(0xFFDCFCE7);
      case 'In Progress':
        return const Color(0xFFDBEAFE);
      default:
        return const Color(0xFFFEF9C3);
    }
  }

  Color get statusTextColor {
    switch (normalizedStatus) {
      case 'Resolved':
        return const Color(0xFF166534);
      case 'In Progress':
        return const Color(0xFF1E3A8A);
      default:
        return const Color(0xFF854D0E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text("Illegal Dumping"),
            subtitle: Text(date),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                normalizedStatus,
                style: TextStyle(
                  color: statusTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(description),
          ),
          if (imageUrl != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(12),
                child: Image.network(
                  imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}