import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GarbageTrackingScreen extends StatefulWidget {
  const GarbageTrackingScreen({super.key});

  @override
  State<GarbageTrackingScreen> createState() => _GarbageTrackingScreenState();
}

class _GarbageTrackingScreenState extends State<GarbageTrackingScreen> {
  late GoogleMapController _mapController;

  static const LatLng _initialPosition = LatLng(6.9271, 79.8612); // Colombo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garbage Truck Tracking'),
      ),
      body: SizedBox.expand( // 🔴 THIS IS THE KEY FIX
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _initialPosition,
            zoom: 13,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
        ),
      ),
    );
  }
}
