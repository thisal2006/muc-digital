import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muc_digital/widgets/app_drawer.dart'; // Add this import for drawer

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  final _nameController = TextEditingController(text: "Praveen Silva");
  final _emailController = TextEditingController(text: "praveen@example.com");
  final _phoneController = TextEditingController(text: "+94 77 123 4567");
  final _addressController = TextEditingController(text: "No. 45, Negombo Road, Maharagama");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                if (_formKey.currentState!.validate()) {
                  setState(() => _isEditing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profile Updated Successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                setState(() => _isEditing = true);
              }
            },
          )
        ],
      ),
      drawer: const AppDrawer(), // Add drawer to profile screen
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Image
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.person,
                      size: 70,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  if (_isEditing)
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF2E7D32),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                        onPressed: () {
                          // TODO: Add image picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Image picker coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 30),

              _buildTextField(
                label: "Full Name",
                controller: _nameController,
                validator: (value) =>
                value!.isEmpty ? "Name cannot be empty" : null,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                label: "Email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                !value!.contains("@") ? "Enter valid email" : null,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                label: "Phone Number",
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value!.length < 10 ? "Enter valid phone number" : null,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                label: "Address",
                controller: _addressController,
                validator: (value) =>
                value!.isEmpty ? "Address cannot be empty" : null,
              ),

              const SizedBox(height: 30),

              const Divider(),

              const SizedBox(height: 10),

              // Booking History
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.white,
                leading: const Icon(Icons.history,
                    color: Color(0xFF2E7D32)),
                title: const Text("Booking History"),
                trailing:
                const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingHistoryScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // Logout
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.white,
                leading:
                const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Log Out",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Confirm Logout"),
                      content: const Text(
                          "Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigate to splash screen or login
                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/',
                                    (route) => false
                            );
                            // TODO: Firebase sign out
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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

// Booking History Screen
class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Booking History"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.local_shipping),
              title: Text("Garbage Pickup - 2025-11-26"),
              subtitle: Text("Both | 8:00 AM - 12:00 PM"),
              trailing: Chip(
                label: Text("Completed"),
              ),
            ),
          ),
          SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(Icons.apartment),
              title: Text("Property Booking - Community Hall"),
              subtitle: Text("2025-12-05 | 2:00 PM - 5:00 PM"),
              trailing: Chip(
                label: Text("Upcoming"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}