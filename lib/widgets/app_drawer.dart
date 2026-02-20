import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header / Profile section with gradient
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2E7D32), // dark green
                  Color(0xFF388E3C), // medium green
                  Color(0xFF66BB6A), // lighter green-orange transition
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Close button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Logo + text centered
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.eco,
                            size: 52,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'MUC Digital',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Maharagama Urban Council',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline, color: Color(0xFF2E7D32)),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined, color: Color(0xFF2E7D32)),
                  title: const Text('Booking History'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to profile screen with tab or open booking history directly
                    // Option 1: Navigate to profile with booking history tab
                    Navigator.pushNamed(context, '/profile').then((_) {
                      // You can add logic here if needed
                    });

                    // Option 2: If you want a separate booking history screen (uncomment below)
                    // Navigator.pushNamed(context, '/booking-history');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report_problem_outlined, color: Color(0xFF2E7D32)),
                  title: const Text('My Complaints'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/complaints');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.phone_in_talk_outlined, color: Color(0xFF2E7D32)),
                  title: const Text('Emergency'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/emergency');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: Color(0xFF2E7D32)),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.pushNamed(context, '/settings');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings screen coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),

                const Divider(height: 32),

                // Footer version info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}