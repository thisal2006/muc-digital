import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.local_shipping,
      'color': Colors.green[700],
      'title': 'Track Garbage Collection',
      'desc': 'Real-time tracking of garbage trucks and schedule pickups with ease',
    },
    {
      'icon': Icons.apartment,
      'color': Colors.orange[700],
      'title': 'Easy Property & Vehicle Booking',
      'desc': 'Book halls, grounds, municipal vehicles in just a few taps',
    },
    {
      'icon': Icons.location_on,
      'color': Colors.blue[700],
      'title': 'Find Locations',
      'desc': 'Locate dump points, cemeteries, and municipal facilities instantly',
    },
    {
      'icon': Icons.notifications_active,
      'color': Colors.purple[700],
      'title': 'Stay Informed & Report Issues',
      'desc': 'Get updates, announcements, file complaints, and access emergency services',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: page['color'],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: page['color'].withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(page['icon'], size: 70, color: Colors.white),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        page['title'],
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page['desc'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                      ),
                    ],
                  ),
                );
              },
            ),

            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Color(0xFF2E7D32),
                    dotColor: Colors.grey,
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 12,
                    expansionFactor: 4,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              left: 32,
              right: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/user_agreement'),
                    child: const Text('Skip', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        Navigator.pushReplacementNamed(context, '/user_agreement');
                      } else {
                        _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Get Started' : 'Next >',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}