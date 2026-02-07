import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property_model.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailsScreen({super.key, required this.property});

  // Function to open Google Maps
  Future<void> _launchMap(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(property.name),
        backgroundColor: const Color(0xFFE67E22), // Orange
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- MAIN IMAGE ---
            Image.asset(
              property.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),

            // --- GALLERY SECTION ---
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: const Text(
                "Gallery",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: property.galleryImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(property.galleryImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            // --- DETAILS SECTION ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Capacity
                  Text(
                    property.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        property.capacity,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- GOOGLE MAP BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if(property.googleMapsUrl.isNotEmpty) {
                          _launchMap(property.googleMapsUrl);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Location link not available yet."))
                          );
                        }
                      },
                      icon: const Icon(Icons.map, color: Color(0xFFE67E22)),
                      label: const Text("View Location on Map", style: TextStyle(color: Color(0xFFE67E22))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE67E22)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Features
                  const Text("Features", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: property.features.map((feature) {
                      return Chip(
                        label: Text(feature),
                        backgroundColor: const Color(0xFFFFF3E0),
                        labelStyle: const TextStyle(color: Color(0xFFE67E22)),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text("About Venue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    property.description,
                    style: const TextStyle(color: Colors.black54, height: 1.5),
                  ),

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),

      // --- BOTTOM BOOK NOW BAR ---
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Starting from", style: TextStyle(color: Colors.grey)),
                Text(
                  property.price,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE67E22),
                  ),
                ),
                const Text("/day", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Booking feature coming soon!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67E22),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Book Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}