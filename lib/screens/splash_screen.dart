import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboarding'); // Or '/user_agreement' if no onboarding
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.orange[700]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.eco, size: 60, color: Colors.green[700]),
              ),
              SizedBox(height: 20),
              Text(
                'MUC Digital',
                style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                'Maharagama Urban Council',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: CircleAvatar(radius: 4, backgroundColor: Colors.white.withOpacity(0.5)),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}