import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/services/auth_service.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/home_screen.dart';
import '../screens/complaints_screen.dart'; 
import '../screens/settings_screen.dart'; // Correct import path after moving

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header / Profile section with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20, bottom: 20),
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
              bottom: false,
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
                                color: Colors.black.withAlpha(38),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Maharagama Urban Council',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
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
                    // Navigator.pushNamed(context, '/booking-history');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report_problem_outlined, color: Color(0xFF2E7D32)),
                  title: const Text('My Complaints'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to complaints history tab (index 1)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComplaintsScreen(initialTabIndex: 1),
                      ),
                    );
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
                    Navigator.pushNamed(context, '/settings');
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
