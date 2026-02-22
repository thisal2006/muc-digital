import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Complaints"),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Color(0xFF2E7D32),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF2E7D32),
            indicatorWeight: 4,
            tabs: [
              Tab(text: "New Complaint"),
              Tab(text: "My Complaints"),
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
  String? _selectedCategory;
  final _descriptionController = TextEditingController();
  File? _attachedImage;

  final _picker = ImagePicker();

  final categories = [
    "Illegal Dumping",
    "Missed Garbage Collection",
    "Street Light Not Working",
    "Road Damage",
    "Water Leakage",
    "Other"
  ];

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _attachedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: const Text("Select Category"),
            items: categories
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
            decoration: _inputDecoration("Category"),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: _inputDecoration("Describe the issue..."),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_photo_alternate),
            label: Text(
                _attachedImage != null ? "Photo Attached" : "Attach Photo"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF2E7D32)),
            ),
          ),
          if (_attachedImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Image.file(_attachedImage!, height: 150),
            ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              if (_selectedCategory == null ||
                  _descriptionController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Please fill all required fields")),
                );
                return;
              }

              // TODO: Upload complaint and image to Firebase / backend

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Complaint submitted successfully"),
                  backgroundColor: Colors.green,
                ),
              );

              setState(() {
                _selectedCategory = null;
                _descriptionController.clear();
                _attachedImage = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Submit Complaint", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF2E7D32)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}

class MyComplaintsList extends StatelessWidget {
  const MyComplaintsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _ComplaintCard(
          title: "Illegal dumping near temple road",
          date: "2025-11-20",
          status: "In Progress",
          statusColor: Colors.orange,
        ),
        _ComplaintCard(
          title: "Street light not working - 3rd lane",
          date: "2025-11-15",
          status: "Resolved",
          statusColor: Colors.green,
        ),
        _ComplaintCard(
          title: "Pothole on High Level Road",
          date: "2025-11-10",
          status: "Pending",
          statusColor: Colors.red,
        ),
      ],
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final Color statusColor;

  const _ComplaintCard({
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(Icons.report_problem, color: statusColor, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(date),
        trailing: Chip(
          label: Text(status),
          backgroundColor: statusColor.withOpacity(0.15),
          labelStyle:
          TextStyle(color: statusColor, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
