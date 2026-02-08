import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property_model.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  // Variable to hold the currently displayed image
  late String selectedImage;

  @override
  void initState() {
    super.initState();
    // Start with the main image
    selectedImage = widget.property.imageUrl;
  }

  // Function to open Google Maps
  Future<void> _launchMap(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // If map fails, show a message instead of crashing/black screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open map: $e")),
      );
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
        //  BACK BUTTON
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // This sends you back to the list
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MAIN HERO IMAGE
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Image.asset(
                selectedImage, // Uses the variable, not the fixed property image
                key: ValueKey<String>(selectedImage),
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),

            // --- GALLERY ---
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: const Text(
                "Gallery (Tap to view)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.property.galleryImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      //UPDATES THE MAIN IMAGE
                      setState(() {
                        selectedImage = widget.property.galleryImages[index];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: selectedImage == widget.property.galleryImages[index]
                            ? Border.all(color: const Color(0xFFE67E22), width: 3) // Orange border if selected
                            : null,
                        image: DecorationImage(
                          image: AssetImage(widget.property.galleryImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            //DETAILS SECTION
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.property.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        widget.property.capacity,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // MAP BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (widget.property.googleMapsUrl.isNotEmpty) {
                          _launchMap(widget.property.googleMapsUrl);
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

                  // FEATURES
                  const Text("Features", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.property.features.map((feature) {
                      return Chip(
                        label: Text(feature),
                        backgroundColor: const Color(0xFFFFF3E0),
                        labelStyle: const TextStyle(color: Color(0xFFE67E22)),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // DESCRIPTION
                  const Text("About Venue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    widget.property.description,
                    style: const TextStyle(color: Colors.black54, height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  // CONTACT INFO
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!)
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, color: Color(0xFFE67E22)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("For more info contact:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(widget.property.contactNumber, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),

      // --- BOTTOM BAR ---
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
                  widget.property.price,
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