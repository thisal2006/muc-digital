import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ComplaintsScreen extends StatefulWidget {
  final int initialTabIndex;
  const ComplaintsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF8),
        appBar: AppBar(
          title: const Text("Complaints Center", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "New Report"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NewComplaintForm(),
            MyComplaintsList(),
          ],
        ),
      ),
    );
  }
}

class NewComplaintForm extends StatefulWidget {
  const NewComplaintForm({super.key});

  @override
  State<NewComplaintForm> createState() => _NewComplaintFormState();
}

class _NewComplaintFormState extends State<NewComplaintForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final _descriptionController = TextEditingController();
  File? _attachedImage;
  bool _isSubmitting = false;
  final _picker = ImagePicker();

  final Map<String, String> categoryHints = {
    "Illegal Dumping": "Typically reviewed within 24 hours.",
    "Missed Garbage Collection": "Collection usually rescheduled for next working day.",
    "Street Light Issue": "Repairs are normally batch-processed weekly.",
    "Road Damage": "Inspection occurs within 3-5 business days.",
    "Water Leakage": "Emergency teams are dispatched within 4-8 hours.",
    "Drainage Blockage": "Manual cleaning scheduled within 48 hours.",
    "Public Nuisance": "Officer investigation within 2 business days.",
    "Other": "Response time varies by issue type."
  };

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 60,
      );
      if (pickedFile != null) {
        setState(() => _attachedImage = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Attach Photo Evidence", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionIcon(Icons.photo_library, "Gallery", () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  }),
                  _actionIcon(Icons.camera_alt, "Camera", () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF2E7D32).withAlpha(26),
            child: Icon(icon, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all required fields"), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    // --- COMMIT 8: Added Confirmation Dialog ---
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Submission"),
        content: Text("Are you sure you want to submit this '$_selectedCategory' report?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("REVIEW")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
            child: const Text("CONFIRM"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      String? imageUrl;
      if (_attachedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('complaints/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(_attachedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('complaints').add({
        'userId': user.uid,
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'imageUrl': imageUrl,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'userEmail': user.email,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Complaint submitted successfully"), backgroundColor: Colors.green),
        );
        setState(() {
          _selectedCategory = null;
          _descriptionController.clear();
          _attachedImage = null;
        });

        DefaultTabController.of(context).animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Submission failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Submit a Complaint", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
            const Text("Help us improve our service by reporting issues", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            _sectionLabel("Complaint Category"),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: categoryHints.keys.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
              decoration: _inputDecoration("Select issue type", Icons.category_outlined),
              validator: (v) => v == null ? "Required" : null,
            ),
            if (_selectedCategory != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  "Notice: ${categoryHints[_selectedCategory]}",
                  style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500),
                ),
              ),
            const SizedBox(height: 24),

            _sectionLabel("Description"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              maxLength: 500,
              decoration: _inputDecoration("Provide details about the issue...", Icons.description_outlined),
              validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
            ),
            const SizedBox(height: 24),

            _sectionLabel("Evidence (Optional)"),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showImageOptions,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _attachedImage != null
                    ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_attachedImage!, fit: BoxFit.cover)),
                    Positioned(top: 8, right: 8, child: CircleAvatar(backgroundColor: Colors.red, radius: 15, child: IconButton(icon: const Icon(Icons.close, size: 15, color: Colors.white), onPressed: () => setState(() => _attachedImage = null)))),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    const Text("Attach a photo", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("SUBMIT COMPLAINT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87));
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
    );
  }
}

class MyComplaintsList extends StatefulWidget {
  const MyComplaintsList({super.key});

  @override
  State<MyComplaintsList> createState() => _MyComplaintsListState();
}

class _MyComplaintsListState extends State<MyComplaintsList> {
  String _searchQuery = "";
  String _selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text("Please login to view history"));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search issues...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.filter_list, color: Color(0xFF2E7D32)),
                  items: ["All", "Pending", "In Progress", "Completed"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedFilter = v!),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('complaints')
                .where('userId', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

              List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

              docs.sort((a, b) {
                Timestamp? t1 = (a.data() as Map<String, dynamic>)['createdAt'];
                Timestamp? t2 = (b.data() as Map<String, dynamic>)['createdAt'];
                if (t1 == null) return -1;
                if (t2 == null) return 1;
                return t2.compareTo(t1);
              });

              var filteredDocs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final category = (data['category'] ?? '').toString().toLowerCase();
                final description = (data['description'] ?? '').toString().toLowerCase();
                final status = data['status'] ?? 'Pending';

                final matchesSearch = category.contains(_searchQuery) || description.contains(_searchQuery);
                final matchesFilter = _selectedFilter == "All" || status == _selectedFilter;

                return matchesSearch && matchesFilter;
              }).toList();

              if (filteredDocs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text("No matching complaints found", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: () => DefaultTabController.of(context).animateTo(0),
                        icon: const Icon(Icons.add, color: Color(0xFF2E7D32)),
                        label: const Text("Submit New Report", style: TextStyle(color: Color(0xFF2E7D32))),
                      )
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {}); // Trigger rebuild
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;
                    final timestamp = data['createdAt'] as Timestamp?;
                    final date = timestamp != null ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate()) : 'Recent';

                    return TweenAnimationBuilder(
                      duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 600)),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Dismissible(
                        key: Key(docId),
                        direction: data['status'] == 'Pending' ? DismissDirection.endToStart : DismissDirection.none,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: const Text("Are you sure you want to remove this report?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("CANCEL")),
                                TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("DELETE", style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          await FirebaseFirestore.instance.collection('complaints').doc(docId).delete();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report deleted successfully")));
                          }
                        },
                        child: _ComplaintHistoryCard(
                          category: data['category'] ?? 'General',
                          description: data['description'] ?? '',
                          status: data['status'] ?? 'Pending',
                          date: date,
                          imageUrl: data['imageUrl'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ComplaintHistoryCard extends StatelessWidget {
  final String category;
  final String description;
  final String status;
  final String date;
  final String? imageUrl;

  const _ComplaintHistoryCard({
    required this.category,
    required this.description,
    required this.status,
    required this.date,
    this.imageUrl,
  });

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Status: $status", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 4),
              Text("Date: $date", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Divider(height: 24),
              const Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description),
              if (imageUrl != null) ...[
                const SizedBox(height: 16),
                const Text("Evidence:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              ]
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'Completed': statusColor = Colors.green; break;
      case 'In Progress': statusColor = Colors.orange; break;
      default: statusColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => _showDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: statusColor.withAlpha(26),
                child: Icon(Icons.report_problem_outlined, color: statusColor, size: 20),
              ),
              title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text(date, style: const TextStyle(fontSize: 12)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withAlpha(26), borderRadius: BorderRadius.circular(20)),
                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
            ),
            if (imageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey)
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}