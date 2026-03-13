import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAgreementScreen extends StatefulWidget {
  const UserAgreementScreen({super.key});

  @override
  State<UserAgreementScreen> createState() => _UserAgreementScreenState();
}

class _UserAgreementScreenState extends State<UserAgreementScreen> {
  bool _agreed = false;

  Future<void> _acceptAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_agreed', true);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/sign_in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Agreement & Consent'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            // FIX: Just go back to the previous screen (Onboarding)
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // White Card
                Expanded(
                  child: Container(
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User Agreement & Consent',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              'By using the MUC Digital mobile application, you agree to the following terms:',
                              style: TextStyle(fontSize: 16, height: 1.6),
                            ),
                            const SizedBox(height: 24),

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
                              'By tapping "Accept & Continue", you confirm that you have read, understood, and accept these terms.',
                              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Last updated: March 2026',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // FIX: Go to Sign In to let the user authenticate.
                      // pushReplacementNamed ensures they can't come back here.
                      Navigator.pushReplacementNamed(context, '/sign_in');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'I Agree',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: _agreed ? _acceptAgreement : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                  ),
                  child: const Text(
                    'Accept & Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

// Custom Bullet Widget
class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18, color: Color(0xFF1B5E20))),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}