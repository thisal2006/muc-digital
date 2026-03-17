import 'package:flutter/material.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<Map<String, String>> _faqs = [
    {"q": "How do I update my profile?", "a": "Go to Settings > Profile Settings to update your name, phone number, and address."},
    {"q": "Can I change my email address?", "a": "Yes, you can update your email in Profile Settings. A verification link will be sent to your new email."},
    {"q": "How do I reset my password?", "a": "If you are logged in, use 'Change Password' in Settings. If logged out, use the 'Forgot Password' link on the Sign In page."},
    {"q": "What are Announcements?", "a": "Announcements are real-time updates from the Municipal Council regarding municipal services and arrival of garbage trucks."},
    {"q": "How do I enable notifications?", "a": "Toggle the 'App Notifications' switch in the Settings menu."},
    {"q": "Is my data secure?", "a": "Yes, we use industry-standard encryption and Firebase Auth to protect your personal information."},
    {"q": "How do I delete my account?", "a": "Go to Settings > Account Actions > Delete Account. Warning: This is permanent."},

  ];

  List<Map<String, String>> _filteredFaqs = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredFaqs = _faqs;
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, String>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _faqs;
    } else {
      results = _faqs
          .where((user) => user["q"]!.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() => _filteredFaqs = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                labelText: 'Search FAQs',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _filteredFaqs.isEmpty
                ? const Center(child: Text("No results found"))
                : ListView.builder(
              itemCount: _filteredFaqs.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ExpansionTile(
                  title: Text(
                    _filteredFaqs[index]['q']!,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(_filteredFaqs[index]['a']!, style: const TextStyle(height: 1.5)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}