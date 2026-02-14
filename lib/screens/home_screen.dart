import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_drawer.dart';
import 'announcements_screen.dart'; // <--- this import is very important

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // All pages that bottom nav can switch to
  final List<Widget> _pages = [
    const _HomeDashboardContent(),           // Home tab (search + cards)
    const Center(child: Text('Bookings - Coming soon')), // Bookings tab
    const AnnouncementsScreen(),             // Updates tab → Announcements
    const Center(child: Text('Chat - Coming soon')),     // Chat tab
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFDFC),
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF1B5E20), size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Text(
            'Welcome Back!',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        actions: [
          // Bell icon now opens Announcements screen
          FadeInRight(
            duration: const Duration(milliseconds: 700),
            child: IconButton(
              icon: Badge(
                label: const Text('3', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.red,
                child: const Icon(Icons.notifications_rounded, color: Color(0xFF1B5E20)),
              ),
              onPressed: () {
                // This is the fix: open Announcements when tapping bell
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnnouncementsScreen()),
                );
              },
            ),
          ),
        ],
      ),

      // Switch between pages when tapping bottom nav
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 16,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // <--- this makes tabs switch
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Updates'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_rounded), label: 'Chat'),
        ],
      ),
    );
  }
}

// Home Dashboard content (search + stats + cards)
class _HomeDashboardContent extends StatefulWidget {
  const _HomeDashboardContent();

  @override
  State<_HomeDashboardContent> createState() => _HomeDashboardContentState();
}

class _HomeDashboardContentState extends State<_HomeDashboardContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _services = [
    {
      'icon': Icons.local_shipping_rounded,
      'title': 'Garbage Tracker',
      'subtitle': 'Track trucks & schedule pickup',
      'color': const Color(0xFF1B5E20),
      'route': '/garbage_tracker',
    },
    {
      'icon': Icons.apartment_rounded,
      'title': 'Property Booking',
      'subtitle': 'Book halls & grounds',
      'color': const Color(0xFFF57C00),
      'route': '/property_booking',
    },
    {
      'icon': Icons.directions_car_rounded,
      'title': 'Vehicle Booking',
      'subtitle': 'Reserve municipal vehicles',
      'color': const Color(0xFF1976D2),
      'route': null,
    },
    {
      'icon': Icons.location_on_rounded,
      'title': 'Cemetery Booking',
      'subtitle': 'Cemetery & crematorium',
      'color': const Color(0xFF7B1FA2),
      'route': null,
    },
    {
      'icon': Icons.emergency_rounded,
      'title': 'Emergency',
      'subtitle': 'Quick contact services',
      'color': const Color(0xFFD32F2F),
      'route': '/emergency',
    },
    {
      'icon': Icons.report_rounded,
      'title': 'Complaints',
      'subtitle': 'File & track complaints',
      'color': const Color(0xFF795548),
      'route': null,
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    if (_searchQuery.isEmpty) return _services;
    final query = _searchQuery.toLowerCase();
    return _services.where((service) {
      return service['title'].toString().toLowerCase().contains(query) ||
          service['subtitle'].toString().toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha:0.06), blurRadius: 12, offset: const Offset(0, 4)),
                  ], //updated
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1B5E20)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FadeInLeft(
                  duration: const Duration(milliseconds: 800),
                  child: _StatCard('3', 'Bookings', Icons.book_online, const Color(0xFF1B5E20)),
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 850),
                  child: _StatCard('1', 'Pending', Icons.hourglass_empty, const Color(0xFFF57C00)),
                ),
                FadeInRight(
                  duration: const Duration(milliseconds: 900),
                  child: _StatCard('2', 'Complaints', Icons.report_problem, const Color(0xFFD32F2F)),
                ),
              ],
            ),
          ),

          // Service cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: GridView.count(
                key: ValueKey<int>(_filteredServices.length),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.9, // Changed this from 1.05 to 0.9
                children: _filteredServices.map((service) {
                  return FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: ServiceCard(
                      icon: service['icon'] as IconData,
                      title: service['title'] as String,
                      subtitle: service['subtitle'] as String,
                      color: service['color'] as Color,
                      route: service['route'] as String?,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _StatCard(String number, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.85)], begin: Alignment.topLeft, end: Alignment.bottomRight), //removed warning
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 8))], //removed warning
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(number, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? route;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          debugPrint("Navigating to: $route");
          if (route != null) {
            Navigator.pushNamed(context, route!);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12), // Reduced padding slightly
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Added min size
            children: [
              // Wrap the icon in Expanded so it shrinks if the text is too long
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.15), // Updated
                        color.withValues(alpha: 0.05)  // Updated
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 40, color: color), // Reduced icon size from 48 to 40
                ),
              ),
              const SizedBox(height: 8), // Reduced gap
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14, // Reduced font size slightly from 16 to 14
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[700]), // Reduced from 13 to 11
                textAlign: TextAlign.center,
                maxLines: 1, // Restrict to 1 line to save space
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//added the property booking route and fixed overflow conflict occured when rendering the deets page