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

class _NewComplaintFormState extends State<NewComplaintForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
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

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _attachedImage = File(pickedFile.path);
      });
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_attachedImage != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Remove Photo"),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _attachedImage = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _submitComplaint() {
    if (_selectedCategory == null || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a category and enter a description"),
          backgroundColor: Colors.red,
        ),
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
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
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
              validator: (value) =>
              value == null ? "Please select a category" : null,
              decoration: _inputDecoration("Category"),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              validator: (value) =>
              (value == null || value.trim().isEmpty) ? "Enter description" : null,
              decoration: _inputDecoration("Describe the issue..."),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _showImageOptions,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(
                  _attachedImage != null ? "Photo Attached" : "Attach Photo"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF2E7D32)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.black26,
              ),
            ),
            if (_attachedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_attachedImage!, height: 150, fit: BoxFit.cover),
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: const Text("Submit Complaint", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
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

class MyComplaintsList extends StatefulWidget {
  const MyComplaintsList({super.key});

  @override
  State<MyComplaintsList> createState() => _MyComplaintsListState();
}

class _MyComplaintsListState extends State<MyComplaintsList> {
  bool _isLoading = false;
  String _searchQuery = "";
  String _filterStatus = "All";

  final List<Map<String, String>> _allComplaints = [
    {
      'title': "Illegal dumping near temple road",
      'date': "2025-11-20",
      'status': "In Progress",
      'statusColor': "orange"
    },
    {
      'title': "Street light not working - 3rd lane",
      'date': "2025-11-15",
      'status': "Resolved",
      'statusColor': "green"
    },
    {
      'title': "Pothole on High Level Road",
      'date': "2025-11-10",
      'status': "Pending",
      'statusColor': "red"
    },
  ];

  List<Map<String, String>> get _filteredComplaints {
    return _allComplaints.where((complaint) {
      final matchesSearch = complaint['title']!
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _filterStatus == "All" || complaint['status'] == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Color _getStatusColor(String colorName) {
    switch (colorName) {
      case "green":
        return Colors.green;
      case "orange":
        return Colors.orange;
      case "red":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _refreshList() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Row
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search complaints...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _filterStatus,
                items: ["All", "Pending", "In Progress", "Resolved"]
                    .map((status) => DropdownMenuItem(
                    value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _filterStatus = value);
                },
              )
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshList,
            child: _filteredComplaints.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No complaints found",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredComplaints.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final complaint = _filteredComplaints[index];
                final color = _getStatusColor(complaint['statusColor']!);
                return _ComplaintCard(
                  title: complaint['title']!,
                  date: complaint['date']!,
                  status: complaint['status']!,
                  statusColor: color,
                );
              },
            ),
          ),
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
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.black26,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
