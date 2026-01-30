import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
   EmergencyScreen({super.key});

  final List<Map<String, String>> contacts = [
    {'name': 'Police Emergency', 'number': '119'},
    {'name': 'Ambulance', 'number': '1990'},
    {'name': 'Fire & Rescue', 'number': '110'},
    {'name': 'MUC Office', 'number': '011285xxxx'},  // replace with real number
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Services')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.phone, color: Colors.red),
              title: Text(contacts[index]['name']!),
              trailing: const Icon(Icons.call),
              onTap: () async {
                final Uri url = Uri(scheme: 'tel', path: contacts[index]['number']);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
