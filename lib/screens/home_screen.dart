import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top stats row (Bookings / Pending / Complaints)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[700],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCard(count: '3', label: 'Bookings', color: Colors.white),
                _StatCard(count: '1', label: 'Pending', color: Colors.orange[200]!),
                _StatCard(count: '2', label: 'Complaints', color: Colors.orange[200]!),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Service grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: const [
                _ServiceCard(icon: Icons.local_shipping, title: 'Garbage Tracker', subtitle: 'Track trucks & schedule pickup', color: Colors.green),
                _ServiceCard(icon: Icons.apartment, title: 'Property Booking', subtitle: 'Book halls & grounds', color: Colors.orange),
                _ServiceCard(icon: Icons.directions_car, title: 'Vehicle Booking', subtitle: 'Reserve municipal vehicles', color: Colors.blue),
                _ServiceCard(icon: Icons.location_on, title: 'Cemetery Booking', subtitle: 'Cemetery & crematorium', color: Colors.purple),
                _ServiceCard(icon: Icons.emergency, title: 'Emergency', subtitle: 'Quick contact services', color: Colors.red),
                _ServiceCard(icon: Icons.report, title: 'Complaints', subtitle: 'File & track complaints', color: Colors.brown),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String count;
  final String label;
  final Color color;

  const _StatCard({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Add navigation later (e.g. to garbage tracker)
          print(' tapped');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
