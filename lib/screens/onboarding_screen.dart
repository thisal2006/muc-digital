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
      'description': 'Real-time tracking of garbage trucks and schedule pickups with ease',
    },
    {
      'icon': Icons.apartment,
      'color': Colors.orange[700],
      'title': 'Easy Property & Vehicle Booking',
      'description': 'Book community halls, grounds, municipal vehicles in just a few taps',
    },
    {
      'icon': Icons.notifications_active,
      'color': Colors.blue[700],
      'title': 'Stay Informed & Report Issues',
      'description': 'Get updates, announcements, file complaints, and access emergency services instantly',
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // PageView for swiping
            PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated icon container
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: page['color'],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: page['color'].withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          page['icon'],
                          size: 80,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Title with fade animation
                      AnimatedOpacity(
                        opacity: _currentPage == index ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          page['title'],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        page['description'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),

                      const Spacer(),

                      // Progress indicator
                      SmoothPageIndicator(
                        controller: _controller,
                        count: _pages.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: const Color(0xFF2E7D32),
                          dotColor: Colors.grey[300]!,
                          dotHeight: 10,
                          dotWidth: 10,
                          spacing: 12,
                          expansionFactor: 4,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/user_agreement'),
                            child: const Text(
                              'Skip',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                          if (_currentPage == _pages.length - 1)
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pushReplacementNamed(context, '/user_agreement'),
                              icon: const Icon(Icons.arrow_forward, color: Colors.white),
                              label: const Text('Get Started', style: TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: () => _controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              ),
                              icon: const Icon(Icons.arrow_forward, color: Colors.white),
                              label: const Text('Next', style: TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),

            // Optional: Close button top right
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pushReplacementNamed(context, '/user_agreement'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}