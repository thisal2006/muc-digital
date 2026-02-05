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

  final Completer<GoogleMapController> _controller = Completer();
  final DatabaseReference _truckRef =
  FirebaseDatabase.instance.ref('trucks');

  final Set<Marker> _markers = {};

  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _listenToTrucks();
  }

  /// ⭐ LISTEN TO ALL TRUCKS
  void _listenToTrucks() {
    _truckRef.onValue.listen((event) async {

      final rawData = event.snapshot.value;

      if (rawData == null) return;

      print("🔥 FIREBASE DATA -> $rawData");

      final data = Map<String, dynamic>.from(rawData as Map);

      final Set<Marker> newMarkers = {};
      final List<LatLng> positions = [];

      data.forEach((truckId, truckData) {

        final truck = Map<String, dynamic>.from(truckData);

        final lat = truck['lat'];
        final lng = truck['lng'];

        if (lat != null && lng != null) {

          final position = LatLng(
            (lat as num).toDouble(),
            (lng as num).toDouble(),
          );

          positions.add(position);

          newMarkers.add(
            Marker(
              markerId: MarkerId(truckId),
              position: position,
              infoWindow: InfoWindow(
                title: truckId,
                snippet: truck['type'] ?? '',
              ),
            ),
          );
        }
      });

      if (!mounted) return;

      setState(() {
        _markers
          ..clear()
          ..addAll(newMarkers);
      });

      /// ⭐ AUTO ZOOM CAMERA (VERY IMPORTANT)
      if (_mapReady && positions.isNotEmpty) {
        final controller = await _controller.future;

        if (positions.length == 1) {
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(positions.first, 15),
          );
        } else {
          controller.animateCamera(
            CameraUpdate.newLatLngBounds(
              _boundsFromLatLngList(positions),
              80,
            ),
          );
        }
      }
    });
  }

  /// ⭐ Calculates map bounds so ALL trucks are visible
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {

    double x0 = list.first.latitude;
    double x1 = list.first.latitude;
    double y0 = list.first.longitude;
    double y1 = list.first.longitude;

    for (LatLng latLng in list) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }

    return LatLngBounds(
      northeast: LatLng(x1, y1),
      southwest: LatLng(x0, y0),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Garbage Truck Live Tracking"),
      ),

      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(6.9271, 79.8612),
          zoom: 13,
        ),

        markers: _markers,

        myLocationEnabled: true,
        myLocationButtonEnabled: true,

        onMapCreated: (controller) {
          _controller.complete(controller);
          _mapReady = true;
        },
      ),
    );
  }
}
