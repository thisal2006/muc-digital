import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'complaints_screen.dart'; // reuses your MyComplaintsList

class MyActivityScreen extends StatefulWidget {
  final int initialTab;
  const MyActivityScreen({super.key, this.initialTab = 0});

  @override
  State<MyActivityScreen> createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('My Activity'), backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white, bottom: TabBar(controller: _tabController, labelColor: Colors.white, unselectedLabelColor: Colors.white70, indicatorColor: Colors.white, tabs: const [Tab(text: 'Bookings'), Tab(text: 'Drafts'), Tab(text: 'Complaints')])),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList('crematorium_bookings', userId, null),     // All crematorium bookings
          _buildList('crematorium_bookings', userId, 'draft'),  // Drafts
          MyComplaintsList(),                                   // Your existing complaints list
        ],
      ),
    );
  }

  Widget _buildList(String collection, String userId, String? status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .whereIf(status != null, 'status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(status == null ? 'No bookings yet' : 'No drafts yet', style: const TextStyle(fontSize: 18, color: Colors.grey)));
        }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(data['timeSlot'] ?? 'Booking'),
                subtitle: Text(DateFormat('dd MMM yyyy • hh:mm a').format(date)),
                trailing: Text('Status: ${data['status'] ?? 'pending'}'),
              ),
            );
          },
        );
      },
    );
  }
}

extension QueryExtension on Query {
  Query whereIf(bool condition, Object field, {Object? isEqualTo}) {
    return condition ? where(field, isEqualTo: isEqualTo) : this;
  }
}