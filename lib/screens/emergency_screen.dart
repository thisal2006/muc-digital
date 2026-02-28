import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('emergency_contacts')
            .orderBy('priority', descending: false) // Correct parameter: descending: false = ascending order
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading contacts:\n${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_missed_rounded, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No emergency contacts available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please check back later or contact MUC',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final contacts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16), // Correct EdgeInsets.all
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final data = contacts[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown';
              final role = data['role'] ?? '';
              final phone = data['phone'] ?? '';
              final priority = data['priority'] as int? ?? 2;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: priority == 1 ? Colors.red[50] : Colors.green[50],
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: priority == 1 ? Colors.red : const Color(0xFF1B5E20),
                    radius: 28,
                    child: Icon(
                      priority == 1 ? Icons.local_police_rounded : Icons.phone_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(role, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        phone,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF1B5E20)),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => _makeCall(context, phone),
                      ),
                      IconButton(
                        icon: const Icon(Icons.message, color: Colors.blue),
                        onPressed: () => _sendSMS(context, phone),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // One-tap call function (receives context)
  Future<void> _makeCall(BuildContext context, String phone) async {
    // Clean the phone number (remove spaces, dashes, etc.)
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    final Uri uri = Uri(scheme: 'tel', path: cleanPhone);

    print('Trying to launch dialer: $uri');

    try {
      // Check if we can launch
      final bool canLaunch = await canLaunchUrl(uri);
      print('Can launch dialer? $canLaunch');

      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback message - tell user what happened
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dialer opened with $cleanPhone (tap call button to dial)'),
            duration: const Duration(seconds: 4),
          ),
        );

        // Try launching again as fallback
        await launchUrl(uri);
      }
    } catch (e) {
      print('Dialer launch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open dialer: $e')),
      );
    }
  }

  // One-tap SMS function (receives context)
  Future<void> _sendSMS(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    final String message = "Emergency! Please send help to my location.";
    final Uri uri = Uri(
      scheme: 'sms',
      path: cleanPhone,
      queryParameters: {'body': message},
    );

    print('Trying to launch SMS: $uri');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open SMS app')),
        );
      }
    } catch (e) {
      print('SMS launch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open SMS: $e')),
      );
    }
  }
}