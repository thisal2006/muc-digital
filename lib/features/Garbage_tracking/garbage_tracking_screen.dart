import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class GarbageTrackingScreen extends StatefulWidget {
  const GarbageTrackingScreen({super.key});

  @override
  State<GarbageTrackingScreen> createState() =>
      _GarbageTrackingScreenState();
}

class _GarbageTrackingScreenState extends State<GarbageTrackingScreen> {

  final DatabaseReference _truckRef =
  FirebaseDatabase.instance.ref('trucks');

  final Completer<GoogleMapController> _mapController = Completer();

  final Map<String, Marker> _markers = {};

  BitmapDescriptor? truckIcon;

  // ⭐ Load custom icon
  Future<void> _loadIcon() async {
    truckIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48,48)),
      'assets/icons/truck.png',
    );
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadIcon();
    _listenToTrucks();
  }

  // ⭐ REALTIME LISTENER
  void _listenToTrucks() {

    _truckRef.onValue.listen((event) async {

      final data = event.snapshot.value;

      if (data == null) return;

      final trucks = Map<String, dynamic>.from(data as Map);

      for (var entry in trucks.entries) {

        final id = entry.key;
        final truck = Map<String, dynamic>.from(entry.value);

        final lat = (truck['lat'] as num).toDouble();
        final lng = (truck['lng'] as num).toDouble();

        final position = LatLng(lat, lng);

        final marker = Marker(
          markerId: MarkerId(id),
          position: position,
          icon: truckIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: "Truck $id",
            snippet: truck['status'] ?? '',
          ),
        );

        _markers[id] = marker;
      }

      if (!mounted) return;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Garbage Truck Tracking"),
      ),

      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(6.9271, 79.8612),
          zoom: 13,
        ),

        markers: _markers.values.toSet(),

        myLocationEnabled: true,
        myLocationButtonEnabled: true,

        onMapCreated: (controller) {
          _mapController.complete(controller);
        },
      ),
    );
  }
}
