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
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
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
            _memberSince = DateFormat('MMMM yyyy').format(createdAt.toDate());
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

    HapticFeedback.heavyImpact();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile Updated Successfully"),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    await Future.wait([
      _loadUserData(),
      _loadStats(),
    ]);
  }

  Future<void> _pickImage() async {
    HapticFeedback.mediumImpact();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => _tempImageFile = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF2E7D32),
        edgeOffset: 100,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsRow(),
                      const SizedBox(height: 32),
                      _buildProfileForm(),
                      const SizedBox(height: 40),
                      _buildAccountActions(),
                      const SizedBox(height: 60),
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

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 220.0,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF2E7D32),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildAvatar(),
              const SizedBox(height: 12),
              Text(
                _nameController.text.isEmpty ? "User Profile" : _nameController.text,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "Member since $_memberSince",
                style: const TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: _isEditing ? "Cancel" : "Edit Profile",
          icon: Icon(_isEditing ? Icons.close : Icons.edit_note, size: 28),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() => _isEditing = !_isEditing);
          },
        ),
        if (_isEditing)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              tooltip: "Save changes",
              icon: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline, size: 28),
              onPressed: _isSaving ? null : _saveProfile,
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _isEditing ? _pickImage : null,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 54,
              backgroundColor: Colors.white,
              backgroundImage: _getProfileImage(),
              child: _getProfileImage() == null
                  ? const Icon(Icons.person, size: 60, color: Color(0xFF2E7D32))
                  : null,
            ),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.add_a_photo, size: 20, color: Color(0xFF2E7D32)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard("Reports", _complaintCount.toString(), Icons.analytics_outlined, Colors.orange),
        const SizedBox(width: 16),
        _buildStatCard("Bookings", _bookingCount.toString(), Icons.event_available_outlined, Colors.blue),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Personal Information"),
          const SizedBox(height: 16),
          _buildModernField("Full Name", _nameController, Icons.person_outline, validator: (v) => v!.isEmpty ? "Name is required" : null),
          const SizedBox(height: 16),
          _buildModernField("NIC Number", _nicController, Icons.badge_outlined, validator: (v) => v!.isNotEmpty && v.length < 10 ? "Invalid NIC" : null),
          const SizedBox(height: 16),
          _buildModernField("Email Address", _emailController, Icons.alternate_email, enabled: false),
          const SizedBox(height: 16),
          _buildModernField("Phone", _phoneController, Icons.phone_iphone_outlined, type: TextInputType.phone),
          const SizedBox(height: 16),
          _buildModernField("Address", _addressController, Icons.map_outlined, maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Account Settings"),
        const SizedBox(height: 16),
        _buildActionTile(
          label: "Logout",
          icon: Icons.logout_rounded,
          color: const Color(0xFF2E7D32),
          onTap: _logout,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          label: "Delete Account",
          icon: Icons.delete_outline_rounded,
          color: Colors.red,
          onTap: _showDeleteAccountDialog,
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.black45,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernField(
      String label,
      TextEditingController controller,
      IconData icon,
      {int maxLines = 1, bool enabled = true, String? Function(String?)? validator, TextInputType type = TextInputType.text}
      ) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing && enabled,
      maxLines: maxLines,
      keyboardType: type,
      validator: validator,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black45, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
        filled: true,
        fillColor: _isEditing && enabled ? Colors.white : Colors.white.withAlpha(100),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildActionTile({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: Icon(Icons.arrow_forward_ios, color: color.withAlpha(100), size: 14),
      ),
    );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, elevation: 0),
            child: const Text("LOGOUT"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _auth.signOut();
      if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignInScreen()), (route) => false);
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
              const Text("This action is permanent. Please enter your password to confirm deletion."),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0),
              child: const Text("DELETE FOREVER"),
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
