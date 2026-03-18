import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About MUC Digital"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text(
                    "MUC Digital",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Our Mission",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 12),
            const Text(
              "To provide fast, transparent, and digital-first access to Maharagama Urban Council services for residents and businesses.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildInfoRow(Icons.calendar_today, "Bookings", "Property, Crematorium, Vehicle"),
            _buildInfoRow(Icons.report_problem, "Complaints", "Report issues easily"),
            _buildInfoRow(Icons.notifications, "Announcements", "Stay updated"),
            _buildInfoRow(Icons.local_shipping, "Garbage Tracking", "Real-time updates"),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "Developed & Maintained by",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              "Maharagama Urban Council\nDigital Transformation Team",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              icon: const Icon(Icons.language),
              label: const Text("Visit Official Website"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                side: const BorderSide(color: Color(0xFF2E7D32)),
              ),
              onPressed: () => _launchUrl("https://maharagama.uc.gov.lk"),
            ),
            const SizedBox(height: 40),
            Text(
              "© ${DateTime.now().year} Maharagama Urban Council",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            ],
          ),
        ],
      ),
    );
  }
}