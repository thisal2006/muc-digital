import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class GarbageTrackingScreen extends StatefulWidget {
  const GarbageTrackingScreen({super.key});

  @override
  State<GarbageTrackingScreen> createState() => _GarbageTrackingScreenState();
}

class _GarbageTrackingScreenState extends State<GarbageTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  final DatabaseReference _truckRef =
  FirebaseDatabase.instance.ref('trucks/truck_01');

  LatLng _truckLocation = const LatLng(6.9271, 79.8612);

  @override
  void initState() {
    super.initState();
    _listenToTruckLocation();
  }

  void _listenToTruckLocation() {
    _truckRef.onValue.listen((event) async {
      final data = event.snapshot.value as Map?;

      if (data != null) {
        final lat = data['lat'];
        final lng = data['lng'];

        if (lat != null && lng != null) {
          setState(() {
            _truckLocation = LatLng(lat.toDouble(), lng.toDouble());
          });

          final controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newLatLng(_truckLocation),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Garbage Truck Live Tracking")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _truckLocation,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("truck"),
            position: _truckLocation,
            infoWindow: const InfoWindow(title: "Garbage Truck"),
          ),
        },
        onMapCreated: (controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
