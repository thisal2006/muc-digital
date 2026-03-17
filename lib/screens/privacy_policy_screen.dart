import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 8),
            Text(
              "Last updated: March 2026",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),

            _buildParagraph(
              "1. Introduction",
              "MUC Digital (Maharagama Urban Council Digital Services) respects your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your data when you use our mobile application.",
            ),
            _buildParagraph(
              "2. Information We Collect",
              "• Account information (name, email, phone number, address)\n"
                  "• Booking and service usage data\n"
                  "• Device information (for app performance and security)\n"
                  "• Uploaded documents (stored securely in Firebase)",
            ),
            _buildParagraph(
              "3. How We Use Your Information",
              "• To provide and improve our services\n"
                  "• To process bookings and complaints\n"
                  "• To communicate with you about your requests\n"
                  "• To ensure security and prevent fraud",
            ),
            _buildParagraph(
              "4. Data Sharing",
              "We do not sell your personal information. We may share data only:\n"
                  "• With authorized council staff for service delivery\n"
                  "• When required by law\n"
                  "• With service providers under strict confidentiality",
            ),
            _buildParagraph(
              "5. Your Rights",
              "You have the right to:\n"
                  "• Access your data\n"
                  "• Request correction or deletion\n"
                  "• Withdraw consent (where applicable)\n\n"
                  "Contact support@mucdigital.lk to exercise these rights.",
            ),
            _buildParagraph(
              "6. Security",
              "We use industry-standard security measures including encryption and access controls. However, no system is 100% secure.",
            ),
            _buildParagraph(
              "7. Contact Us",
              "For questions about this policy:\n"
                  "Email: support@mucdigital.lk\n"
                  "Phone: +94 112 850 265",
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                "Thank you for trusting MUC Digital",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}