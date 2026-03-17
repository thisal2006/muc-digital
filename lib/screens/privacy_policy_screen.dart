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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Version 1.0.2 | Effective Date: March 2026",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const Divider(height: 40, thickness: 1),

            _buildSection("1. OVERVIEW",
                "This Privacy Policy describes how Maharagama Urban Council ('we', 'us', or 'our') collects, uses, and shares your personal information when you use the MUC Digital mobile application. By using the Service, you agree to the collection and use of information in accordance with this policy."),

            _buildSection("2. DATA COLLECTION AND TYPES",
                "While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you. This includes, but is not limited to:\n\n"
                    "• Full Name and Identification Details\n"
                    "• Personal Phone Number and Email Address\n"
                    "• Residential Address within the Municipality\n"
                    "• Precise Geographic Location Data\n"
                    "• Device Information (IP Address, OS version, Unique Device IDs)"),

            _buildSection("3. USE OF LOCATION DATA",
                "This app requires access to background location services to provide real-time updates for municipal utilities, such as garbage truck arrival tracking and emergency response dispatch. Location data is processed securely and is never sold to third-party advertisers."),

            _buildSection("4. THIRD-PARTY SERVICES",
                "We utilize Google Firebase for authentication, cloud storage, and analytics. These third-party services may collect information used to identify you. We recommend reviewing the Google Privacy Policy to understand how they handle data at a platform level."),

            _buildSection("5. DATA RETENTION POLICY",
                "We will retain your Personal Data only for as long as is necessary for the purposes set out in this Privacy Policy. We will retain and use your Personal Data to the extent necessary to comply with our legal obligations under Sri Lankan law, resolve disputes, and enforce our legal agreements."),

            _buildSection("6. SECURITY OF DATA",
                "The security of your data is important to us. We implement administrative, technical, and physical security measures designed to protect your personal information from unauthorized access and disclosure. However, no method of transmission over the Internet is 100% secure, and we cannot guarantee absolute security."),

            _buildSection("7. YOUR DATA PROTECTION RIGHTS",
                "Under certain circumstances, you have the following data protection rights:\n\n"
                    "• The right to access, update or delete the information we have on you.\n"
                    "• The right of rectification if that information is inaccurate.\n"
                    "• The right to withdraw consent at any time where we relied on your consent to process your personal information."),

            _buildSection("8. CHILDREN'S PRIVACY",
                "Our Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. If you are a parent or guardian and you are aware that your child has provided us with Personal Data, please contact us."),

            _buildSection("9. AMENDMENTS TO THIS POLICY",
                "We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the 'Last Updated' date at the top of this policy."),

            _buildSection("10. CONTACT INFORMATION",
                "If you have any questions about this Privacy Policy, you can contact the Maharagama Urban Council Administration:\n\n"
                    "Address: Maharagama, Sri Lanka\n"
                    "Phone: 0112 850 265\n"
                    "Email: privacy@muc.gov.lk"),

            const SizedBox(height: 50),
            const Center(
              child: Text(
                "End of Privacy Policy",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)
          ),
          const SizedBox(height: 10),
          Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black)
          ),
        ],
      ),
    );
  }
}