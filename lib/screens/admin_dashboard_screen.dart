import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Controllers for forms
  final _announcementTitleController = TextEditingController();
  final _announcementDescriptionController = TextEditingController();
  final _propertyNameController = TextEditingController();
  final _propertyLocationController = TextEditingController();
  final _propertyPriceController = TextEditingController();

  bool _isLoading = false;

  // Add announcement
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification sent!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Add property
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property added!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Update booking status
  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking $newStatus!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Mark report resolved
  Future<void> _markReportResolved(String reportId) async {
    try {
      await FirebaseFirestore.instance.collection('dumping_reports').doc(reportId).update({'status': 'resolved'});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report resolved!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Update property (example for edit)
  Future<void> _updateProperty(String propertyId, Map<String, dynamic> updates) async {
    try {
      await FirebaseFirestore.instance.collection('properties').doc(propertyId).update(updates);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property updated!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _viewPhoto(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open photo')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
      body: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Notifications'),
                Tab(text: 'Bookings'),
                Tab(text: 'Dumping Reports'),
                Tab(text: 'Properties'),
                Tab(text: 'Users'),
              ],
              indicatorColor: Color(0xFF1B5E20),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Notifications: Form + List
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(controller: _announcementTitleController, decoration: const InputDecoration(labelText: 'Title')),
                        const SizedBox(height: 8),
                        TextField(controller: _announcementDescriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _addAnnouncement,
                          child: const Text('Send Notification'),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance.collection('announcements').orderBy('timestamp', descending: true).snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final docs = snapshot.data!.docs;
                                return ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (ctx, i) => ListTile(title: Text(docs[i]['title']), subtitle: Text(docs[i]['description'])),
                                );
                              }
                              return const Center(child: CircularProgressIndicator());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bookings: List with details + approve/reject
                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final docs = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (ctx, i) {
                            final data = docs[i].data();
                            return Card(
                              child: ListTile(
                                title: Text(data['type'] ?? 'Booking'),
                                subtitle: Text('User: ${data['user_id']} | Status: ${data['status']} | Details: ${data['details']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(icon: const Icon(Icons.check), onPressed: () => _updateBookingStatus(docs[i].id, 'approved')),
                                    IconButton(icon: const Icon(Icons.close), onPressed: () => _updateBookingStatus(docs[i].id, 'rejected')),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  // Dumping Reports: List + view photo + resolve
                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('dumping_reports').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final docs = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (ctx, i) {
                            final data = docs[i].data();
                            return Card(
                              child: ListTile(
                                title: Text(data['location'] ?? 'Location'),
                                subtitle: Text(data['description'] ?? 'Description'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(icon: const Icon(Icons.image), onPressed: () => _viewPhoto(data['photo_url'] ?? '')),
                                    IconButton(icon: const Icon(Icons.done), onPressed: () => _markReportResolved(docs[i].id)),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  // Properties: Form + List + Edit
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(controller: _propertyNameController, decoration: const InputDecoration(labelText: 'Name')),
                        TextField(controller: _propertyLocationController, decoration: const InputDecoration(labelText: 'Location')),
                        TextField(controller: _propertyPriceController, decoration: const InputDecoration(labelText: 'Price')),
                        ElevatedButton(onPressed: _addProperty, child: const Text('Add Property')),
                        Expanded(
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance.collection('properties').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final docs = snapshot.data!.docs;
                                return ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (ctx, i) {
                                    final data = docs[i].data();
                                    return ListTile(
                                      title: Text(data['name'] ?? 'Name'),
                                      subtitle: Text('${data['location']} | Price: ${data['price']}'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          // Simple edit example - expand as needed
                                          _updateProperty(docs[i].id, {'name': 'Updated Name'}); // Replace with form dialog
                                        },
                                      ),
                                    );
                                  },
                                );
                              }
                              return const Center(child: CircularProgressIndicator());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Users: List with details
                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final docs = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (ctx, i) {
                            final data = docs[i].data();
                            return Card(
                              child: ListTile(
                                title: Text(data['name'] ?? 'Name'),
                                subtitle: Text('Email: ${data['email']} | Phone: ${data['phone']}'),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
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