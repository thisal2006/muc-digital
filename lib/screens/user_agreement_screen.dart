import 'package:flutter/material.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Agreement & Consent'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'By creating an account or using the MUC Digital mobile application, you agree to the following:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              BulletPoint(text: 'You are a resident or authorized user of services provided by the Maharagama Urban Council (MUC).'),
              BulletPoint(text: 'You consent to the collection, processing, and use of your personal information (name, contact details, location for garbage tracking, booking history) strictly for providing municipal services.'),
              BulletPoint(text: 'You agree to receive notifications, announcements, and service-related updates from the Maharagama Urban Council through the app.'),
              BulletPoint(text: 'You will use the application responsibly and only for lawful purposes.'),
              BulletPoint(text: 'The app is provided "as is" for demonstration and academic purposes as part of the Software Development Group Project (5COSC021C) by Group CS-33, Informatics Institute of Technology / University of Westminster.'),
              SizedBox(height: 24),
              Text('By tapping "I Agree" or "Accept", you confirm that you have read, understood, and accept these terms.'),
              SizedBox(height: 8),
              Text('Last updated: January 2026'),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                  child: Text('I Agree'),
                ),
              ),
            ],
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
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}