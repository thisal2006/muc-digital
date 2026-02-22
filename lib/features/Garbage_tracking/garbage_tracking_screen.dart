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
  final Map<String, LatLng> _targetPositions = {};
  final Map<String, Timer> _movementTimers = {};

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
      const ImageConfiguration(size: Size(40, 40)),
      "assets/icons/truck.png",
    );

    await _getUserLocation();
    _listenToTrucks();
  }

  //--------------------------------------------------
  // USER LOCATION
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

    if (permission == LocationPermission.deniedForever) return;

    _userPosition =
    await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
    );
  }

  //--------------------------------------------------
  // UBER-STYLE SMOOTH MOVEMENT ENGINE
  //--------------------------------------------------

  void _startSmoothMovement(String truckId) {

    _movementTimers[truckId]?.cancel();

    _movementTimers[truckId] =
        Timer.periodic(const Duration(milliseconds: 40), (timer) {

          if (!_markers.containsKey(truckId) ||
              !_targetPositions.containsKey(truckId)) {
            timer.cancel();
            return;
          }

          LatLng current = _markers[truckId]!.position;
          LatLng target = _targetPositions[truckId]!;

          double latDiff = target.latitude - current.latitude;
          double lngDiff = target.longitude - current.longitude;

          double distance =
          (latDiff.abs() + lngDiff.abs());

          // If very close → stop micro jitter
          if (distance < 0.00001) {
            return;
          }

          // Smooth factor (adjust for speed)
          double stepFactor = 0.08;

          LatLng newPos = LatLng(
            current.latitude + (latDiff * stepFactor),
            current.longitude + (lngDiff * stepFactor),
          );

          _markers[truckId] = Marker(
            markerId: MarkerId(truckId),
            position: newPos,
            icon: truckIcon ??
                BitmapDescriptor.defaultMarker,
            infoWindow:
            InfoWindow(title: "Truck $truckId"),
          );

          if (mounted) setState(() {});
        });
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

    if (distance < 500 &&
        !_nearbyAlertShown) {

      _nearbyAlertShown = true;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "🚛 Garbage truck is nearby!"),
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

            // First appearance
            if (!_markers.containsKey(id)) {

              _markers[id] = Marker(
                markerId: MarkerId(id),
                position: newPosition,
                icon: truckIcon ??
                    BitmapDescriptor.defaultMarker,
                infoWindow:
                InfoWindow(title: "Truck $id"),
              );

              _targetPositions[id] =
                  newPosition;

              _startSmoothMovement(id);

            } else {

              // Update target only
              _targetPositions[id] =
                  newPosition;
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
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
        const DumpPointsScreen(),
        transitionsBuilder:
            (_, animation, __, child) {

          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
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

    for (var timer in _movementTimers.values) {
      timer.cancel();
    }

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
              LatLng(6.8480, 79.9260),
              zoom: 14,
            ),
            markers:
            _markers.values.toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled:
            true,
            onMapCreated:
                (controller) {
              _mapController
                  .complete(controller);
            },
          ),

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
                    icon:
                    Icons.calendar_month,
                    label: "Schedule",
                    color: Colors.green,
                    onTap: () {},
                  ),

                  _actionButton(
                    icon: Icons.delete,
                    label: "Dump Points",
                    color: Colors.teal,
                    onTap:
                    _openDumpPoints,
                  ),

                  _actionButton(
                    icon:
                    Icons.warning_amber,
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
            decoration:
            BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child:
            Icon(icon, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
