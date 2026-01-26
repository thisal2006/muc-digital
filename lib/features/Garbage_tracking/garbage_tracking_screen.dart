import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GarbageTrackingScreen extends StatefulWidget {
  const GarbageTrackingScreen({super.key});

  @override
  State<GarbageTrackingScreen> createState() => _GarbageTrackingScreenState();
}

class _GarbageTrackingScreenState extends State<GarbageTrackingScreen> {
  GoogleMapController? _mapController;
  Timer? _timer;
  int _index = 0;

  // 🔴 LONG ROUTE — SO YOU WILL SEE MOVEMENT
  final List<LatLng> _route = const [
    LatLng(6.8485, 79.9260),
    LatLng(6.8492, 79.9268),
    LatLng(6.8500, 79.9277),
    LatLng(6.8508, 79.9286),
    LatLng(6.8516, 79.9296),
    LatLng(6.8524, 79.9306),
    LatLng(6.8532, 79.9316),
    LatLng(6.8540, 79.9326),
    LatLng(6.8548, 79.9336),
  ];

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();

    _markers.add(
      Marker(
        markerId: const MarkerId('truck'),
        position: _route.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      ),
    );

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: _route,
        color: Colors.green,
        width: 5,
      ),
    );
  }

  void _startMovement() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_index >= _route.length) {
        timer.cancel();
        return;
      }

      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('truck'),
            position: _route[_index],
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        };
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_route[_index]),
      );

      _index++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garbage Truck Tracking'),
        backgroundColor: Colors.green,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _route.first,
          zoom: 16,
        ),
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (controller) {
          _mapController = controller;
          _startMovement(); // 🚨 THIS IS THE KEY
        },
      ),
    );
  }
}
