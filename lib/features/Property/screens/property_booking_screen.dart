import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muc_digital/models/property_model.dart';
import 'property_details_screen.dart';


class PropertyBookingScreen extends StatelessWidget {
  const PropertyBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("DEBUG: BUILDING BOOKING SCREEN"); // Check if this shows in terminal

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Property Booking",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFE67E22),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFFE67E22),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search venues...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none
                ),
              ),
            ),
          ),
          // List
          Expanded(
            child: ListView.builder(
              itemCount: dummyProperties.length,
              itemBuilder: (context, index) {
                return PropertyCard(property: dummyProperties[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Property property;
  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //behavior: HitTestBehavior.opaque is CRITICAL for clicks to work
      behavior: HitTestBehavior.opaque,
      onTap: () {
        print("DEBUG: CLICKED ON ${property.name}");
        //rootNavigator: true is the "Nuclear Option" to force the push
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => PropertyDetailsScreen(property: property),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(property.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(property.name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(property.capacity, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Text(property.price, style: const TextStyle(color: Color(0xFFE67E22), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//ready to commit
//go