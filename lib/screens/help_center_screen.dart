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
    {"q": "Why am I not receiving notifications?", "a": "Ensure notifications are enabled in both the app settings and your phone's system settings."},
    {"q": "Can I use the app offline?", "a": "Most features require an internet connection to sync with the database, but cached data may be visible."},
    {"q": "What is the version of this app?", "a": "You can find the version number at the very bottom of the Settings screen."},
    {"q": "How do I report a bug?", "a": "Use the 'Help Center' to find our contact details and send us a screenshot of the issue."},
    {"q": "Can I have multiple accounts?", "a": "Each account must be linked to a unique email address."},
    {"q": "How do I log out?", "a": "Tap 'Log Out' at the bottom of the Settings screen."},
    {"q": "Where can I find the Privacy Policy?", "a": "The Privacy Policy link is located in the Support section of the Settings screen."},
    {"q": "Does the app track my location?", "a": "We only collect location data if explicitly required for specific campus services, with your permission."},
    {"q": "How do I refresh announcements?", "a": "The announcements list updates automatically, but you can navigate away and back to force a reload."},
    {"q": "Who can see my phone number?", "a": "Your phone number is only visible to you and the system administrators."},
    {"q": "Can I change the app theme?", "a": "Currently, the app follows the standard MUC brand colors, but Dark Mode support is coming soon."},
    {"q": "Is there a web version?", "a": "MUC Digital is currently optimized for Android mobile devices."},
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

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            child: const Column(
              children: [
                Text("Need more help?", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  "0112 850 265",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                ),
                Text("Maharagama Urban Council Support", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // Logic for calling will be added here once i make that screen
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.call, color: Colors.white),
        label: const Text("Call Council", style: TextStyle(color: Colors.white)),
      ),

    );
  }
}