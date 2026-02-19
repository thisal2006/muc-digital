import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

import '../dump_points/presentation/dump_points_screen.dart';
import '../illegal_dumping/presentation/illegal_dumping_screen.dart';

class GarbageTrackingScreen extends StatefulWidget {
  const GarbageTrackingScreen({super.key});

  @override
  State<GarbageTrackingScreen> createState() =>
      _GarbageTrackingScreenState();
}

class _GarbageTrackingScreenState extends State<GarbageTrackingScreen> {

  //--------------------------------------------------
  // FIREBASE
  //--------------------------------------------------

  final DatabaseReference _truckRef =
  FirebaseDatabase.instance.ref('trucks');

  StreamSubscription? _truckSubscription;

  //--------------------------------------------------
  // MAP
  //--------------------------------------------------

  final Completer<GoogleMapController> _mapController =
  Completer();

  final Map<String, Marker> _markers = {};
  final Map<String, LatLng> _truckPositions = {};

  /// Prevent animation stacking
  final Map<String, bool> _isAnimating = {};

  BitmapDescriptor? truckIcon;

  //--------------------------------------------------
  // USER LOCATION
  //--------------------------------------------------

  Position? _userPosition;
  bool _nearbyAlertShown = false;

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
      const ImageConfiguration(
        size: Size(48,48),
      ),
      "assets/icons/truck.png",
    );


    await _getUserLocation();

    _listenToTrucks();
  }

  //--------------------------------------------------
  // LOCATION
  //--------------------------------------------------

  Future<void> _getUserLocation() async {

    bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return;

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
      await Geolocator.requestPermission();
    }

    if (permission ==
        LocationPermission.deniedForever) return;

    _userPosition =
    await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
    );
  }

  //--------------------------------------------------
  // SMOOTH MOVEMENT (LOCKED)
  //--------------------------------------------------

  Future<void> _animateTruck(
      String truckId,
      LatLng oldPos,
      LatLng newPos,
      ) async {

    if (_isAnimating[truckId] == true) return;

    _isAnimating[truckId] = true;

    const steps = 25;
    const delay = Duration(milliseconds: 35);

    double latStep =
        (newPos.latitude - oldPos.latitude) / steps;

    double lngStep =
        (newPos.longitude - oldPos.longitude) / steps;

    for (int i = 0; i < steps; i++) {

      final interpolated = LatLng(
        oldPos.latitude + (latStep * i),
        oldPos.longitude + (lngStep * i),
      );

      /// ⭐ REMOVE OLD MARKER
      _markers.remove(truckId);

      /// ⭐ CREATE NEW MARKER (FORCES REDRAW)
      _markers[truckId] = Marker(
        markerId: MarkerId(truckId),
        position: interpolated,
        icon: truckIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: "Truck $truckId",
        ),
      );

      if (mounted) {
        setState(() {});
      }

      await Future.delayed(delay);
    }

    _isAnimating[truckId] = false;
  }


  //--------------------------------------------------
  // NEARBY ALERT
  //--------------------------------------------------

  void _checkNearbyTruck(LatLng truckPosition) {

    if (_userPosition == null) return;

    double distance =
    Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      truckPosition.latitude,
      truckPosition.longitude,
    );

    if (distance < 500 && !_nearbyAlertShown) {

      _nearbyAlertShown = true;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text("🚛 Garbage truck is nearby!"),
          backgroundColor: Colors.green,
        ),
      );
    }

    if (distance > 700) {
      _nearbyAlertShown = false;
    }
  }

  //--------------------------------------------------
  // FIREBASE LISTENER
  //--------------------------------------------------

  void _listenToTrucks() {

    _truckSubscription =
        _truckRef.onValue.listen((event) {

          final data = event.snapshot.value;
          if (data == null) return;

          final trucks =
          Map<String, dynamic>.from(data as Map);

          for (var entry in trucks.entries) {

            final id = entry.key;
            final truck =
            Map<String, dynamic>.from(entry.value);

            final lat =
            (truck['lat'] as num).toDouble();
            final lng =
            (truck['lng'] as num).toDouble();

            final newPosition =
            LatLng(lat, lng);

            //----------------------------------
            // FIRST LOAD
            //----------------------------------

            if (!_truckPositions.containsKey(id)) {

              _truckPositions[id] = newPosition;

              _markers[id] = Marker(
                markerId: MarkerId(id),
                position: newPosition,
                icon: truckIcon ??
                    BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(
                  title: "Truck $id",
                  snippet: truck['status'] ?? '',
                ),
              );

            } else {

              final oldPosition =
              _truckPositions[id]!;

              _animateTruck(
                  id,
                  oldPosition,
                  newPosition);

              _truckPositions[id] = newPosition;
            }

            _checkNearbyTruck(newPosition);
          }

          if (mounted) setState(() {});
        });
  }

  //--------------------------------------------------
  // NAVIGATION
  //--------------------------------------------------

  void _openDumpPoints() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const DumpPointsScreen(),
      ),
    );
  }

  void _openIllegalDumpReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const IllegalDumpingScreen(),
      ),
    );
  }

  //--------------------------------------------------
  // DISPOSE
  //--------------------------------------------------

  @override
  void dispose() {
    _truckSubscription?.cancel();
    super.dispose();
  }

  //--------------------------------------------------
  // UI
  //--------------------------------------------------

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
            "Live Garbage Truck Tracking"),
      ),

      body: Stack(
        children: [

          GoogleMap(
            initialCameraPosition:
            const CameraPosition(
              target:
              LatLng(6.9271, 79.8612),
              zoom: 13,
            ),
            markers: _markers.values.toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _mapController.complete(
                  controller);
            },
          ),

          //----------------------------------
          // BOTTOM BUTTONS
          //----------------------------------

          Positioned(
            bottom: 20,
            left: 12,
            right: 12,
            child: Container(
              padding:
              const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.1),
                    blurRadius: 12,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [

                  _actionButton(
                    icon: Icons.calendar_month,
                    label: "Schedule",
                    color: Colors.green,
                    onTap: () {},
                  ),

                  _actionButton(
                    icon: Icons.delete,
                    label: "Dump Points",
                    color: Colors.teal,
                    onTap: _openDumpPoints,
                  ),

                  _actionButton(
                    icon: Icons.warning_amber,
                    label: "Report",
                    color: Colors.orange,
                    onTap:
                    _openIllegalDumpReport,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------
  // BUTTON
  //--------------------------------------------------

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [

          Container(
            padding:
            const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
              color.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child:
            Icon(icon, color: color),
          ),

          const SizedBox(height: 6),

          Text(
            label,
            style:
            const TextStyle(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}