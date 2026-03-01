import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: "Praveen Silva");
  final _emailController = TextEditingController(text: "praveen@example.com");
  final _phoneController = TextEditingController(text: "+94 77 123 4567");
  final _addressController =
  TextEditingController(text: "No. 45, Negombo Road, Maharagama");

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile =
    await _picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
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
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Avatar UI (from Commit 4)
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? const Icon(Icons.person,
                            size: 70, color: Color(0xFF2E7D32))
                            : null,
                      ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 30),

              _buildField("Full Name", _nameController),
              const SizedBox(height: 16),

              _buildField("Email", _emailController),
              const SizedBox(height: 16),

              _buildField("Phone Number", _phoneController),
              const SizedBox(height: 16),

              _buildField("Address", _addressController),

              const SizedBox(height: 32),

              ListTile(
                leading:
                const Icon(Icons.history, color: Color(0xFF2E7D32)),
                title: const Text("Booking History"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BookingHistoryScreen()),
                  );
                },
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Log Out",
                    style: TextStyle(color: Colors.red)),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    TextInputType keyboardType = TextInputType.text;

    if (label == "Email") {
      keyboardType = TextInputType.emailAddress;
    } else if (label == "Phone Number") {
      keyboardType = TextInputType.phone;
    }

    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label cannot be empty";
        }

        if (label == "Email" &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return "Enter a valid email address";
        }

        if (label == "Phone Number") {
          final cleaned = value.replaceAll(RegExp(r'\D'), '');
          if (cleaned.length < 10) {
            return "Enter a valid phone number";
          }
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.grey[100],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

//
// ✅ Reusable Booking Tile Widget
//
class BookingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;

  const BookingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Chip(
        label: Text(status),
      ),
    );
  }
}

//
// Booking History Screen
//
class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking History"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          BookingTile(
            icon: Icons.local_shipping,
            title: "Garbage Pickup - 2025-11-26",
            subtitle: "Both | 8:00 AM - 12:00 PM",
            status: "Completed",
          ),
          BookingTile(
            icon: Icons.apartment,
            title: "Property Booking - Community Hall",
            subtitle: "2025-12-05 | 2:00 PM - 5:00 PM",
            status: "Upcoming",
          ),
        ],
      ),
    );
  }
}
