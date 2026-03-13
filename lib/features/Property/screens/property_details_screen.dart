import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property_model.dart';
import 'booking_form_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  late String selectedImage;

  @override
  void initState() {
    super.initState();
    selectedImage = widget.property.imageUrl;
  }

  Future<void> _launchMap() async {
    final Uri url = Uri.parse(widget.property.googleMapsUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open maps application")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.property.name),
        backgroundColor: const Color(0xFFE67E22),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(selectedImage, width: double.infinity, height: 250, fit: BoxFit.cover),

                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 16),
                    child: Text("Gallery", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    height: 90,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      itemCount: widget.property.galleryImages.length,
                      itemBuilder: (context, index) {
                        final imgPath = widget.property.galleryImages[index];
                        final isSelected = selectedImage == imgPath;
                        return GestureDetector(
                          onTap: () => setState(() => selectedImage = imgPath),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFE67E22) : Colors.transparent,
                                width: 2,
                              ),
                              image: DecorationImage(image: AssetImage(imgPath), fit: BoxFit.cover),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Facilities", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: widget.property.features.map((f) => Chip(
                            label: Text(f, style: const TextStyle(fontSize: 13)),
                            backgroundColor: const Color(0xFFE67E22).withValues(alpha: 0.1),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          )).toList(),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _launchMap,
                            icon: const Icon(Icons.map, color: Color(0xFFE67E22)),
                            label: const Text("Navigate to Map", style: TextStyle(color: Color(0xFFE67E22))),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE67E22)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Text("Contact", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final Uri phoneUri = Uri.parse('tel:${widget.property.contactNumber.replaceAll(" ", "")}');
                            if (!await launchUrl(phoneUri)) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch dialer")));
                            }
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE67E22).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.phone, color: Color(0xFFE67E22), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(widget.property.contactNumber, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(widget.property.description, style: const TextStyle(fontSize: 14, height: 1.5)),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BOTTOM BUTTON BAR
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE67E22),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // SAVE TO FIRESTORE
                    await FirebaseFirestore.instance.collection('property_bookings').add({
                      'user_id': user.uid,
                      'property_name': widget.property.name,
                      'price': widget.property.price,
                      'status': 'pending',
                      'timestamp': FieldValue.serverTimestamp(),

                      'date': 'March 20, 2026',
                      'slot': '09:00 AM - 05:00 PM',
                      'purpose': 'Event',
                      'crowd_size': '100',
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booking request submitted!')),
                      );
                      // NAVIGATE TO NEXT SCREEN
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BookingFormScreen(property: widget.property)),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to book')));
                  }
                },
                child: const Text("BOOK NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}