import 'package:flutter/material.dart';
import '../models/property_model.dart'; // Import the data

class PropertyBookingScreen extends StatefulWidget {
  const PropertyBookingScreen({super.key});

  @override
  State<PropertyBookingScreen> createState() => _PropertyBookingScreenState();
}

class _PropertyBookingScreenState extends State<PropertyBookingScreen> {
  // set index 1 (Bookings) to be active in nav bar
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 1. TOP APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFFE67E22), // The Orange Color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigator.pop(context); // Enable this when having a previous screen
          },
        ),
        title: const Text(
          "Property Booking",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      // 2. THE LIST OF PROPERTIES
      body: ListView.builder(
        // Add padding at bottom so the last card isn't hidden by the nav bar
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        itemCount: dummyProperties.length,
        itemBuilder: (context, index) {
          final property = dummyProperties[index];
          return PropertyCard(property: property);
        },
      ),

      // 3. BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green, // Active color (Green)
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Updates"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// CUSTOM WIDGET: THE CARD UI
// ---------------------------------------------------------
class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              property.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(height: 150, color: Colors.grey[300], child: const Icon(Icons.broken_image));
              },
            ),
          ),

          // TEXT DETAILS
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  property.price,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE67E22), // Orange Text
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      property.capacity,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}