import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _announcementTitleController = TextEditingController();
  final _announcementDescriptionController = TextEditingController();
  final _propertyNameController = TextEditingController();
  final _propertyLocationController = TextEditingController();
  final _propertyPriceController = TextEditingController();

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
        const SnackBar(content: Text('Notification sent successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending notification: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addProperty() async {
    if (_propertyNameController.text.isEmpty || _propertyLocationController.text.isEmpty || _propertyPriceController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('properties').add({
        'name': _propertyNameController.text.trim(),
        'location': _propertyLocationController.text.trim(),
        'price': double.parse(_propertyPriceController.text.trim()),
        'available': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _propertyNameController.clear();
      _propertyLocationController.clear();
      _propertyPriceController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding property: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking $newStatus!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating booking: $e')),
      );
    }
  }

  Future<void> _markReportResolved(String reportId) async {
    try {
      await FirebaseFirestore.instance.collection('dumping_reports').doc(reportId).update({
        'status': 'resolved',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report marked as resolved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating report: $e')),
      );
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
        length: 5, // Added Users tab
        child: Column(
          children: [
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Notifications'),
                Tab(text: 'Bookings'),
                Tab(text: 'Dumping Reports'),
                Tab(text: 'Add Properties'),
                Tab(text: 'Users'),
              ],
              indicatorColor: Color(0xFF1B5E20),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Notifications tab: Add form + list of sent announcements
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Send Notification', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _announcementTitleController,
                          decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _announcementDescriptionController,
                          decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _addAnnouncement,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Send', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 24),
                        const Text('Sent Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('announcements').orderBy('timestamp', descending: true).snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                              if (snapshot.hasError) return const Center(child: Text('Error loading announcements'));
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No announcements'));
                              final announcements = snapshot.data!.docs;
                              return ListView.builder(
                                itemCount: announcements.length,
                                itemBuilder: (context, index) {
                                  final data = announcements[index].data() as Map<String, dynamic>;
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      title: Text(data['title'] ?? 'No title'),
                                      subtitle: Text(data['description'] ?? 'No description'),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bookings tab: Real-time list with full details, approve/reject for pending
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (snapshot.hasError) return const Center(child: Text('Error loading bookings'));
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No bookings available'));
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
                          final status = data['status'] ?? 'pending';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('Name: $name'),
                              subtitle: Text('Address: $address\nDate: $date\nSlot: $slot\nStatus: $status'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (status == 'pending') ...[
                                    IconButton(
                                      icon: const Icon(Icons.check, color: Colors.green),
                                      onPressed: () => _updateBookingStatus(bookings[index].id, 'approved'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () => _updateBookingStatus(bookings[index].id, 'rejected'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Dumping Reports tab: List with details, photo view, mark resolved
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('dumping_reports').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (snapshot.hasError) return const Center(child: Text('Error loading reports'));
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No dumping reports available'));
                      final reports = snapshot.data!.docs;
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final data = reports[index].data() as Map<String, dynamic>;
                          final location = data['location'] ?? 'No location';
                          final description = data['description'] ?? 'No description';
                          final photoUrl = data['photo_url'] ?? '';
                          final status = data['status'] ?? 'pending';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('Location: $location'),
                              subtitle: Text('Description: $description\nStatus: $status'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.image, color: Colors.green),
                                    onPressed: () => _viewPhoto(photoUrl),
                                  ),
                                  if (status != 'resolved')
                                    IconButton(
                                      icon: const Icon(Icons.done_all, color: Colors.blue),
                                      onPressed: () => _markReportResolved(reports[index].id),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Add Properties tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Add Property', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _propertyNameController,
                          decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _propertyLocationController,
                          decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _propertyPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Price (LKR)', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _addProperty,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Add', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),

                  // Users tab: List all users with details
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (snapshot.hasError) return const Center(child: Text('Error loading users'));
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No users available'));
                      final users = snapshot.data!.docs;
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final data = users[index].data() as Map<String, dynamic>;
                          final name = data['name'] ?? 'Unknown';
                          final email = data['email'] ?? 'No email';
                          final phone = data['phone'] ?? 'No phone';
                          final address = data['address'] ?? 'No address';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('Name: $name'),
                              subtitle: Text('Email: $email\nPhone: $phone\nAddress: $address'),
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

  Future<void> _viewPhoto(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open photo')));
    }
  }
}