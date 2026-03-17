import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Policy for MUC Digital",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Last Updated: March 2024",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const Divider(height: 30),
            _buildSection("1. Introduction",
                "Welcome to MUC Digital, the official mobile application for the Maharagama Urban Council. We are committed to protecting your personal information and your right to privacy."),
            _buildSection("2. Information We Collect",
                "We collect personal information that you provide to us such as name, phone number, and address when you register on the app. We also collect location data to provide municipal services like garbage truck tracking."),
            _buildSection("3. How We Use Your Information",
                "We use the information we collect to provide, operate, and maintain our services, including real-time announcements and emergency assistance."),
            _buildSection("4. Data Security",
                "We use Firebase Authentication and industry-standard encryption to keep your data safe. However, no electronic transmission over the internet is 100% secure."),
            _buildSection("5. Contact Us",
                "If you have questions or comments about this policy, you may contact us at the Maharagama Urban Council office or via our official support number: 0112 850 265."),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                "© 2024 Maharagama Urban Council",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
        ],
      ),
    );
  }
}