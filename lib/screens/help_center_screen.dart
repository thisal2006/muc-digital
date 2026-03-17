import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            icon: Icons.question_answer,
            title: "Frequently Asked Questions",
            content:
            "Browse common questions and answers about using MUC Digital services.",
          ),
          const SizedBox(height: 24),
          _buildSection(
            icon: Icons.contact_support,
            title: "Contact Support",
            content:
            "Email: support@mucdigital.lk\n"
                "Phone: +94 112 850 265 (Mon–Fri, 8:30 AM – 4:30 PM)\n\n"
                "Our team usually responds within 24–48 hours.",
          ),
          const SizedBox(height: 24),
          _buildSection(
            icon: Icons.book_online,
            title: "Booking Related Help",
            content:
            "• How do I book a crematorium slot?\n"
                "• How can I track my property booking?\n"
                "• What documents are required?\n\n"
                "Detailed guides coming soon.",
          ),
          const SizedBox(height: 24),
          _buildSection(
            icon: Icons.report_problem,
            title: "Report a Problem",
            content:
            "If something isn't working:\n"
                "1. Go to Complaints → New Report\n"
                "2. Describe the issue clearly\n"
                "3. Attach screenshots if possible",
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              "We're here to help!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2E7D32), size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}