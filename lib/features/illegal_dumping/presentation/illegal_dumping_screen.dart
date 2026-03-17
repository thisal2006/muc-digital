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

class _IllegalDumpingScreenState
    extends State<IllegalDumpingScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF8),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          title: const Text("Illegal Dumping"),
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
      _showError("Fill all fields");
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

        "userId": user.uid, // ⭐ IMPORTANT
        "description": descriptionController.text,
        "imageUrl": imageUrl,
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
        "location": GeoPoint(
          position.latitude,
          position.longitude,
        ),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report submitted")),
      );

      DefaultTabController.of(context).animateTo(1);

    } catch (e) {
      _showError(e.toString());
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [

          GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(),
              ),
              child: imageFile == null
                  ? const Center(child: Text("Add Photo"))
                  : Image.file(imageFile!, fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Description",
            ),
          ),

          const SizedBox(height: 20),

          if (isUploading)
            LinearProgressIndicator(value: uploadProgress),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: submitReport,
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// HISTORY
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
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No reports"));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {

            final data =
            docs[index].data() as Map<String, dynamic>;

            return ListTile(
              title: Text(data['description'] ?? ''),
              subtitle: Text(
                data['createdAt'] != null
                    ? DateFormat('dd MMM yyyy')
                    .format((data['createdAt'] as Timestamp).toDate())
                    : '',
              ),
            );
          },
        );
      },
    );
  }
}