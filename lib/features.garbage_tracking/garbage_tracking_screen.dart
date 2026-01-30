import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GarbageTrackingScreen extends StatefulWidget {
  const GarbageTrackingScreen({super.key});

  @override
  State<GarbageTrackingScreen> createState() => _GarbageTrackingScreenState();
}

class _GarbageTrackingScreenState extends State<GarbageTrackingScreen> {
  bool _mapReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Garbage Truck Tracking"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.9271, 79.8612),
              zoom: 14,
            ),
            onMapCreated: (controller) {
              setState(() {
                _mapReady = true;
              });
            },
          ),
          if (!_mapReady)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
