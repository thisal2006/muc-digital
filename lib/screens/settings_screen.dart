import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/auth/sign_in_screen.dart';
import '../widgets/change_password_form.dart';
import '../widgets/edit_profile_form.dart';
import 'about_screen.dart';
import 'help_center_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _notificationsEnabled = true;

  User? get currentUser => _auth.currentUser;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _auth.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                      (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isDeleting = false;
    bool obscurePassword = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Delete Account", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("This action is permanent. Enter your password to confirm."),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: isDeleting ? null : () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isDeleting = true);
                try {
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: currentUser!.email!,
                    password: passwordController.text.trim(),
                  );
                  await currentUser!.reauthenticateWithCredential(credential);
                  await _firestore.collection('users').doc(currentUser!.uid).delete();
                  await currentUser!.delete();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                          (route) => false,
                    );
                  }
                } catch (e) {
                  setDialogState(() => isDeleting = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete Forever", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(title: "Account"),
            _buildSettingsCard([
              _SettingsTile(
                icon: Icons.person_outline,
                title: "Profile Settings",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileForm())),
              ),
              _SettingsTile(
                icon: Icons.lock_reset_outlined,
                title: "Change Password",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordForm())),
              ),
            ]),
            const SizedBox(height: 24),
            const _SectionHeader(title: "Notifications"),
            _buildSettingsCard([
              _SettingsTile(
                icon: Icons.notifications_none_outlined,
                title: "App Notifications",
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeColor: const Color(0xFF2E7D32),
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                ),
                onTap: () => setState(() => _notificationsEnabled = !_notificationsEnabled),
              ),
            ]),
            const SizedBox(height: 24),
            const _SectionHeader(title: "Support"),
            _buildSettingsCard([
              _SettingsTile(
                icon: Icons.help_outline,
                title: "Help Center",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen())),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: "Privacy Policy",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: "About App",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutAppScreen())),
              ),
            ]),
            const SizedBox(height: 40),
            const Text("ACCOUNT ACTIONS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            const SizedBox(height: 12),
            _buildSettingsCard([
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.orange),
                title: const Text("Log Out"),
                onTap: _showLogoutDialog,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text("Delete Account", style: TextStyle(color: Colors.red)),
                onTap: _showDeleteAccountDialog,
              ),
            ]),
            const SizedBox(height: 40),
            const Center(child: Text("Version 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 12),
    child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  const _SettingsTile({required this.icon, required this.title, required this.onTap, this.trailing});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF2E7D32).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
    ),
    title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    onTap: onTap,
  );
}