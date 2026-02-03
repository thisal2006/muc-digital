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
    //_listenToTruckLocation();
  }

  void _listenToTruckLocation() {
    _truckRef.onValue.listen((event) async {
      try {

        if (!event.snapshot.exists) return;

        final data = Map<String, dynamic>.from(
            event.snapshot.value as Map);

        final lat = data['lat'];
        final lng = data['lng'];

        if (lat == null || lng == null) return;

        setState(() {
          _truckLocation = LatLng(
            (lat as num).toDouble(),
            (lng as num).toDouble(),
          );
        });

        final controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newLatLng(_truckLocation),
        );

      } catch (e) {
        print("Firebase parsing error: $e");
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Garbage Truck Live Tracking")),
      body: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: true,

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
