import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/auth/sign_in_screen.dart';

// New screens (create these files in lib/screens/settings/ or same folder)
import 'help_center_screen.dart';
import 'privacy_policy_screen.dart';
import 'about_app_screen.dart';

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

  // Notification toggle state
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    if (currentUser == null) return;
    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    if (mounted && doc.exists && doc.data()!.containsKey('notificationsEnabled')) {
      setState(() {
        _notificationsEnabled = doc.data()!['notificationsEnabled'] as bool;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (currentUser == null) return;
    setState(() => _notificationsEnabled = value);
    await _firestore.collection('users').doc(currentUser!.uid).set({
      'notificationsEnabled': value,
    }, SetOptions(merge: true));
  }

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

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Change Password"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                  ),
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: obscureOld,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => obscureOld = !obscureOld),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmNewPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final oldPass = oldPasswordController.text.trim();
                final newPass = newPasswordController.text.trim();
                final confirmPass = confirmNewPasswordController.text.trim();

                if (newPass != confirmPass) {
                  setDialogState(() => errorMsg = "New passwords do not match");
                  return;
                }
                if (newPass.length < 6) {
                  setDialogState(() => errorMsg = "Password must be at least 6 characters");
                  return;
                }

                try {
                  final credential = EmailAuthProvider.credential(
                    email: currentUser!.email!,
                    password: oldPass,
                  );
                  await currentUser!.reauthenticateWithCredential(credential);
                  await currentUser!.updatePassword(newPass);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password changed successfully")),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  setDialogState(() {
                    errorMsg = e.code == 'wrong-password' ? 'Incorrect current password' : e.message;
                  });
                } catch (e) {
                  setDialogState(() => errorMsg = 'Failed to change password');
                }
              },
              child: const Text("Change"),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isDeleting = false;
    bool obscurePassword = true;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Delete Account", style: TextStyle(color: Colors.red)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "This action is permanent and cannot be undone.",
                  style: TextStyle(color: Colors.red[700]),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Enter your password to confirm',
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                if (errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: isDeleting
                  ? null
                  : () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isDeleting = true);

                try {
                  final credential = EmailAuthProvider.credential(
                    email: currentUser!.email!,
                    password: passwordController.text.trim(),
                  );
                  await currentUser!.reauthenticateWithCredential(credential);
                  await currentUser!.delete();
                  await _firestore.collection('users').doc(currentUser!.uid).delete();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                          (route) => false,
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  setDialogState(() {
                    errorMsg = e.code == 'wrong-password' ? 'Incorrect password' : e.message;
                  });
                } catch (e) {
                  setDialogState(() => errorMsg = 'Failed to delete account');
                } finally {
                  if (mounted) setDialogState(() => isDeleting = false);
                }
              },
              child: isDeleting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                  : const Text("Delete Account"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          _buildSettingsCard([
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF2E7D32)),
              title: const Text("Edit Profile"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileForm()),
                );
              },
            ),
          ]),

          const SizedBox(height: 24),

          // Account Section
          _SectionHeader(title: "Account"),
          _buildSettingsCard([
            _SettingsTile(
              icon: Icons.lock_outline,
              title: "Change Password",
              onTap: _showChangePasswordDialog,
            ),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: "App Notifications",
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: const Color(0xFF2E7D32),
                onChanged: _toggleNotifications,
              ),
              onTap: () => _toggleNotifications(!_notificationsEnabled),
            ),
          ]),

          const SizedBox(height: 24),

          // Support Section
          _SectionHeader(title: "Support & Info"),
          _buildSettingsCard([
            _SettingsTile(
              icon: Icons.help_outline,
              title: "Help Center",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
              ),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
            _SettingsTile(
              icon: Icons.info_outline,
              title: "About App",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutAppScreen()),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Danger Zone
          _SectionHeader(title: "Danger Zone"),
          _buildSettingsCard([
            _SettingsTile(
              icon: Icons.logout,
              title: "Log Out",
              onTap: _showLogoutDialog,
            ),
            _SettingsTile(
              icon: Icons.delete_forever,
              title: "Delete Account",
              onTap: _showDeleteAccountDialog,
            ),
          ]),
        ],
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
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 13, color: Colors.grey)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}