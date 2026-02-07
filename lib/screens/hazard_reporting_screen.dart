import 'package:flutter/material.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Complaints"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: "New Complaint"),
              Tab(text: "My Complaints"),
            ],
            labelColor: const Color(0xFF2E7D32),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF2E7D32),
            onTap: (index) => setState(() => _selectedTab = index),
          ),
          Expanded(
            child: _selectedTab == 0
                ? const NewComplaintForm()
                : const MyComplaintsList(),
          ),
        ],
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
  bool _imageAttached = false;

  final categories = [
    "Illegal Dumping",
    "Missed Garbage Collection",
    "Street Light Not Working",
    "Road Damage",
    "Water Leakage",
    "Other"
  ];

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
          const SizedBox(height: 20),

          TextField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: _inputDecoration("Describe the issue..."),
          ),
          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: () {
              // TODO: image picker
              setState(() => _imageAttached = true);
            },
            icon: const Icon(Icons.add_photo_alternate),
            label: Text(_imageAttached ? "Image Attached" : "Attach Photo"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: () {
              if (_selectedCategory == null || _descriptionController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all required fields")),
                );
                return;
              }
              // TODO: send to Firebase / backend
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Complaint submitted successfully")),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.report_problem, color: Colors.red),
        title: Text(title),
        subtitle: Text(date),
        trailing: Chip(
          label: Text(status),
          backgroundColor: statusColor.withOpacity(0.2),
          labelStyle: TextStyle(color: statusColor),
        ),
      ),
    );
  }
}