import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _announcementTitleController = TextEditingController();
  final _announcementDescriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addAnnouncement() async {
    if (_announcementTitleController.text.isEmpty || _announcementDescriptionController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('announcements').add({
        'title': _announcementTitleController.text.trim(),
        'description': _announcementDescriptionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _announcementTitleController.clear();
      _announcementDescriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding announcement: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Notifications'),
                Tab(text: 'Bookings'),
              ],
              indicatorColor: Color(0xFF1B5E20),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Notifications tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Add New Announcement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _announcementTitleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _announcementDescriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _addAnnouncement,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Add Announcement'),
                        ),
                      ],
                    ),
                  ),

                  // Bookings tab
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(child: Text('Error loading bookings'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No bookings available'));
                      }

                      final bookings = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final data = bookings[index].data() as Map<String, dynamic>;
                          final name = data['name'] ?? 'Unknown';
                          final address = data['address'] ?? 'No address';
                          final date = data['date'] ?? 'No date';
                          final slot = data['slot'] ?? 'No slot';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('Name: $name'),
                              subtitle: Text('Address: $address\nDate: $date\nSlot: $slot'),
                              trailing: IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                onPressed: () {
                                  // Approve booking logic (e.g. update status in Firestore)
                                  FirebaseFirestore.instance
                                      .collection('bookings')
                                      .doc(bookings[index].id)
                                      .update({'status': 'approved'});
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking approved')));
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}