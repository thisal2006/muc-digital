import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: "Praveen Silva");
  final _emailController = TextEditingController(text: "praveen@example.com");
  final _phoneController = TextEditingController(text: "+94 77 123 4567");
  final _addressController =
  TextEditingController(text: "No. 45, Negombo Road, Maharagama");

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile =
    await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          )
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _isEditing ? () => _pickImage(ImageSource.gallery) : null,
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: const Color(0xFF2E7D32),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null
                              ? const Icon(Icons.person, size: 70, color: Color(0xFF2E7D32))
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ProfileField(label: "Full Name", controller: _nameController, enabled: _isEditing),
                    const SizedBox(height: 16),
                    ProfileField(label: "Email", controller: _emailController, enabled: _isEditing, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    ProfileField(label: "Phone Number", controller: _phoneController, enabled: _isEditing, keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    ProfileField(label: "Address", controller: _addressController, enabled: _isEditing),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
                        );
                      },
                      child: const Text("View Booking History", style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.4), // Fixed .withValues error
                child: const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;

  const ProfileField({
    super.key,
    required this.label,
    required this.controller,
    required this.enabled,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> bookings = [
      {'title': "Garbage Pickup", 'subtitle': "2025-11-26 | Completed", 'status': "Completed"},
      {'title': "Community Hall", 'subtitle': "2025-12-05 | Upcoming", 'status': "Upcoming"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Booking History"), backgroundColor: const Color(0xFF2E7D32)),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            child: ListTile(
              title: Text(booking['title']!),
              subtitle: Text(booking['subtitle']!),
              trailing: Text(booking['status']!,
                  style: TextStyle(color: booking['status'] == "Completed" ? Colors.green : Colors.orange)),
            ),
          );
        },
      ),
    );
  }
}