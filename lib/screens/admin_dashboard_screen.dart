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

  Future<void> _approveBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': 'approved',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking approved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving booking: $e')),
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
        length: 4,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Notifications'),
                Tab(text: 'Bookings'),
                Tab(text: 'Dumping Reports'),
                Tab(text: 'Add Properties'),
              ],
              indicatorColor: Color(0xFF1B5E20),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Notifications tab (add/send)
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
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Send'),
                        ),
                      ],
                    ),
                  ),

                  // Bookings tab (view details + approve)
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
                          final status = data['status'] ?? 'pending';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('Name: $name'),
                              subtitle: Text('Address: $address\nDate: $date\nSlot: $slot\nStatus: $status'),
                              trailing: status == 'pending' ? IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => _approveBooking(bookings[index].id),
                              ) : null,
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Dumping Reports tab (view with photos)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('dumping_reports').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(child: Text('Error loading reports'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No dumping reports available'));
                      }

                      final reports = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final data = reports[index].data() as Map<String, dynamic>;
                          final location = data['location'] ?? 'No location';
                          final description = data['description'] ?? 'No description';
                          final photoUrl = data['photo_url'] ?? '';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('Location: $location'),
                              subtitle: Text('Description: $description'),
                              trailing: IconButton(
                                icon: const Icon(Icons.image, color: Colors.green),
                                onPressed: () => _viewPhoto(photoUrl),
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
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Add'),
                        ),
                      ],
                    ),
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
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open photo')));
    }
  }
}