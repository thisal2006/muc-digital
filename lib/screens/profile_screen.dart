import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'auth/sign_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  int _complaintCount = 0;
  int _bookingCount = 0;
  String _memberSince = "---";

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _nicController;

  File? _tempImageFile;
  String? _photoUrl;

  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  User? get currentUser => _auth.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _emailController = TextEditingController();
    _nicController = TextEditingController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
    _loadUserData();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (currentUser == null) return;
    try {
      final complaintSnapshot = await _firestore
          .collection('complaints')
          .where('userId', isEqualTo: currentUser!.uid)
          .get();

      final bookingSnapshot = await _firestore
          .collection('crematorium_bookings')
          .where('userId', isEqualTo: currentUser!.uid)
          .get();

      if (mounted) {
        setState(() {
          _complaintCount = complaintSnapshot.docs.length;
          _bookingCount = bookingSnapshot.docs.length;
        });
      }
    } catch (e) {
      debugPrint("Error loading stats: $e");
    }
  }

  Future<void> _loadUserData() async {
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _emailController.text = data['email'] ?? currentUser!.email ?? '';
          _nicController.text = data['nic'] ?? '';
          _photoUrl = data['photoUrl'];

          final createdAt = data['createdAt'] as Timestamp?;
          if (createdAt != null) {
            _memberSince = DateFormat('MMM yyyy').format(createdAt.toDate());
          }
        });
      } else {
        _emailController.text = currentUser!.email ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);
    try {
      String? newUrl = _photoUrl;
      if (_tempImageFile != null) {
        final ref = _storage.ref().child('profiles/${currentUser!.uid}.jpg');
        await ref.putFile(_tempImageFile!);
        newUrl = await ref.getDownloadURL();
      }

      await _firestore.collection('users').doc(currentUser!.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'nic': _nicController.text.trim(),
        'photoUrl': newUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _photoUrl = newUrl;
        _tempImageFile = null;
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    await _loadUserData();
    await _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF2E7D32),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              pinned: true,
              backgroundColor: const Color(0xFF2E7D32),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)]),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _isEditing ? _pickImage : null,
                        child: Tooltip(
                          message: "Tap to change photo",
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white24,
                            backgroundImage: _getProfileImage(),
                            child: _getProfileImage() == null 
                                ? const Icon(Icons.camera_alt, size: 30, color: Colors.white) 
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(_nameController.text, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("Member Since: $_memberSince", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  tooltip: _isEditing ? "Cancel" : "Edit Profile",
                  icon: Icon(_isEditing ? Icons.close : Icons.edit_note, size: 28),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isEditing = !_isEditing);
                  },
                ),
                if (_isEditing)
                  IconButton(
                      tooltip: "Save Changes",
                      icon: _isSaving 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.done_all),
                      onPressed: _isSaving ? null : _saveProfile
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildStatCard("Complaints", _complaintCount.toString(), Icons.report_problem_outlined, Colors.orange),
                          const SizedBox(width: 15),
                          _buildStatCard("Bookings", _bookingCount.toString(), Icons.calendar_today_outlined, Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("Personal Information"),
                            const SizedBox(height: 15),
                            _buildModernField("Full Name", _nameController, Icons.person_outline),
                            const SizedBox(height: 16),
                            _buildModernField("NIC Number", _nicController, Icons.badge_outlined),
                            const SizedBox(height: 16),
                            _buildModernField("Phone", _phoneController, Icons.phone_android_outlined),
                            const SizedBox(height: 16),
                            _buildModernField("Address", _addressController, Icons.location_on_outlined, maxLines: 2),
                            const SizedBox(height: 40),
                            _sectionTitle("Security & Account"),
                            const SizedBox(height: 15),
                            _buildActionTile(
                              label: "Logout",
                              icon: Icons.logout,
                              color: const Color(0xFF2E7D32),
                              onTap: _logout,
                            ),
                            const SizedBox(height: 12),
                            _buildActionTile(
                              label: "Delete Account",
                              icon: Icons.delete_forever_outlined,
                              color: Colors.red,
                              onTap: _showDeleteAccountDialog,
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
      ),
    );
  }

  Widget _buildActionTile({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withAlpha(100)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => _tempImageFile = File(pickedFile.path));
    }
  }

  ImageProvider? _getProfileImage() {
    if (_tempImageFile != null) return FileImage(_tempImageFile!);
    if (_photoUrl != null && _photoUrl!.isNotEmpty) return CachedNetworkImageProvider(_photoUrl!);
    return null;
  }

  Future<void> _logout() async {
    HapticFeedback.heavyImpact();
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to sign out of your account?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("LOGOUT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _auth.signOut();
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
    }
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Delete Account", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("This action is permanent and cannot be undone. Please enter your password to confirm."),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                try {
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: currentUser!.email!,
                    password: passwordController.text.trim(),
                  );
                  await currentUser!.reauthenticateWithCredential(credential);
                  await _firestore.collection('users').doc(currentUser!.uid).delete();
                  await currentUser!.delete();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignInScreen()), (route) => false);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Delete Forever"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _nicController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
