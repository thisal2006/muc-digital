import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  final _nameController = TextEditingController(text: "Praveen Silva");
  final _emailController = TextEditingController(text: "praveen@example.com");
  final _phoneController = TextEditingController(text: "+94 77 123 4567");
  final _addressController = TextEditingController(text: "No. 45, Negombo Road, Maharagama");

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
              onPressed: () {
                // TODO: save to Firebase / backend
                setState(() => _isEditing = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile updated")),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, size: 70, color: Color(0xFF2E7D32)),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF2E7D32),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: () {
                          // TODO: image picker
                        },
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Name
            _buildField("Full Name", _nameController, _isEditing),

            const SizedBox(height: 16),

            // Email
            _buildField("Email", _emailController, _isEditing),

            const SizedBox(height: 16),

            // Phone
            _buildField("Phone Number", _phoneController, _isEditing),

            const SizedBox(height: 16),

            // Address
            _buildField("Address", _addressController, _isEditing),

            const SizedBox(height: 32),

            // Booking History Button
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF2E7D32)),
              title: const Text("Booking History"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
                );
              },
            ),

            const Divider(),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Log Out", style: TextStyle(color: Colors.red)),
              onTap: () {
                // TODO: Firebase sign out
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, bool editable) {
    return TextField(
      controller: controller,
      enabled: editable,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: editable ? Colors.white : Colors.grey[100],
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

// Simple Booking History Screen (placeholder)
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
          ListTile(
            leading: Icon(Icons.local_shipping),
            title: Text("Garbage Pickup - 2025-11-26"),
            subtitle: Text("Both | 8:00 AM - 12:00 PM"),
            trailing: Chip(label: Text("Completed")),
          ),
          ListTile(
            leading: Icon(Icons.apartment),
            title: Text("Property Booking - Community Hall"),
            subtitle: Text("2025-12-05 | 2:00 PM - 5:00 PM"),
            trailing: Chip(label: Text("Upcoming")),
          ),
          // Add more...
        ],
      ),
    );
  }
}