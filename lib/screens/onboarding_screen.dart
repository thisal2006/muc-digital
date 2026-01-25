import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green[700],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.local_shipping, size: 80, color: Colors.white),
            ),
            SizedBox(height: 40),
            Text(
              'Track Garbage Collection',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Real-time tracking of garbage trucks\nand schedule pickups with ease',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 20, height: 4, color: Colors.green[700]),
                SizedBox(width: 8),
                CircleAvatar(radius: 4, backgroundColor: Colors.grey[300]),
                SizedBox(width: 8),
                CircleAvatar(radius: 4, backgroundColor: Colors.grey[300]),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/user_agreement');
                  },
                  child: Text('Skip', style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: () {}, // Add more onboarding pages if needed
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                  child: Text('Next >'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}