import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_management_service.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  // --- STATE VARIABLES GO HERE (OUTSIDE THE BUILD METHOD) ---
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final _service = ProfileManagementService();
  bool _isLoading = false;


  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Full Name", _nameController, Icons.person),
            _buildTextField("Email Address", _emailController, Icons.email),
            _buildTextField("Phone Number", _phoneController, Icons.phone),
            _buildTextField("Home Address", _addressController, Icons.home),

          ],
        ),
      ),
    );
  }
}
//go