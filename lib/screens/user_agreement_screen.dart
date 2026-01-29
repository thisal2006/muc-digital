import 'package:flutter/material.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E7D32), Color(0xFFFF7043)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // White card with text
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'User Agreement & Consent',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'By creating an account or using the MUC Digital mobile application, you agree to the following:',
                            style: TextStyle(fontSize: 15, height: 1.5),
                          ),
                          const SizedBox(height: 20),

                          const BulletPoint(
                            text: 'You are a resident or authorized user of services provided by the Maharagama Urban Council (MUC).',
                          ),
                          const BulletPoint(
                            text: 'You consent to the collection, processing, and use of your personal information (name, contact details, location for garbage tracking, booking history) strictly for providing municipal services.',
                          ),
                          const BulletPoint(
                            text: 'You agree to receive notifications, announcements, and service-related updates from the Maharagama Urban Council through the app.',
                          ),
                          const BulletPoint(
                            text: 'You will use the application responsibly and only for lawful purposes.',
                          ),
                          const BulletPoint(
                            text: 'The app is provided "as is" for demonstration and academic purposes as part of the Software Development Group Project (5COSC021C) by Group CS-33, Informatics Institute of Technology / University of Westminster.',
                          ),

                          const SizedBox(height: 32),

                          const Text(
                            'By tapping "I Agree" or "Accept", you confirm that you have read, understood, and accept these terms.',
                            style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Last updated: January 2026',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // I Agree button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // This line makes the button work
                        Navigator.pushReplacementNamed(context, '/home'); // or '/phone_login' if you have it
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                      ),
                      child: const Text(
                        'I Agree',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 20, color: Colors.black87)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, height: 1.45))),
        ],
      ),
    );
  }
}