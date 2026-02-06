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

class _GarbageTrackingScreenState extends State<GarbageTrackingScreen>
    with TickerProviderStateMixin {

  final DatabaseReference _truckRef =
  FirebaseDatabase.instance.ref('trucks');

  final Completer<GoogleMapController> _mapController = Completer();

  final Map<String, Marker> _markers = {};
  final Map<String, LatLng> _truckPositions = {};

  BitmapDescriptor? truckIcon;

  //--------------------------------------------------
  // INIT
  //--------------------------------------------------

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    truckIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      "assets/icons/truck.png",
      width: 70,
      height: 70,
    );

    _listenToTrucks(); // ⭐ YOU FORGOT THIS
  }

  //--------------------------------------------------
  // SMOOTH MOVEMENT (NO CONTROLLERS NEEDED)
  //--------------------------------------------------

  Future<void> _animateTruck(
      String truckId,
      LatLng oldPos,
      LatLng newPos,
      ) async {

    const steps = 30; // higher = smoother
    const delay = Duration(milliseconds: 30);

    double latStep =
        (newPos.latitude - oldPos.latitude) / steps;

    double lngStep =
        (newPos.longitude - oldPos.longitude) / steps;

    for (int i = 0; i < steps; i++) {

      final interpolated = LatLng(
        oldPos.latitude + (latStep * i),
        oldPos.longitude + (lngStep * i),
      );

      if (_markers.containsKey(truckId)) {
        _markers[truckId] = _markers[truckId]!.copyWith(
          positionParam: interpolated,
        );

        if (mounted) {
          setState(() {});
        }
      }

      await Future.delayed(delay);
    }
  }

  //--------------------------------------------------
  // FIREBASE LISTENER
  //--------------------------------------------------

  void _listenToTrucks() {

    _truckRef.onValue.listen((event) {

      final data = event.snapshot.value;
      if (data == null) return;

      final trucks = Map<String, dynamic>.from(data as Map);

      for (var entry in trucks.entries) {

        final id = entry.key;
        final truck = Map<String, dynamic>.from(entry.value);

        final lat = (truck['lat'] as num).toDouble();
        final lng = (truck['lng'] as num).toDouble();

        final newPosition = LatLng(lat, lng);

        //----------------------------------------
        // FIRST LOAD
        //----------------------------------------

        if (!_truckPositions.containsKey(id)) {

          _truckPositions[id] = newPosition;

          _markers[id] = Marker(
            markerId: MarkerId(id),
            position: newPosition,
            icon: truckIcon ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: "Truck $id",
              snippet: truck['status'] ?? '',
            ),
          );

        } else {

          //----------------------------------------
          // SMOOTH MOVE
          //----------------------------------------

          final oldPosition = _truckPositions[id]!;

          _animateTruck(id, oldPosition, newPosition);

          _truckPositions[id] = newPosition;
        }
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  //--------------------------------------------------
  // UI
  //--------------------------------------------------

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
