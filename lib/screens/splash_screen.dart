import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF006400), Color(0xFFFF8C00)], // dark green → orange
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Icon(Icons.eco, size: 60, color: Colors.green)),
              SizedBox(height: 20),
              Text('MUC Digital', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Maharagama Urban Council', style: TextStyle(fontSize: 18, color: Colors.white)),
              SizedBox(height: 80),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Dot(), Dot(), Dot(),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  const Dot({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: CircleAvatar(radius: 5, backgroundColor: Colors.white.withOpacity(0.5)),
  );
}