import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

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
  // GOOGLE API KEY
  //--------------------------------------------------

  final String googleAPIKey =
      "AIzaSyACUjnMs8ntXloajN-wJx9rr4eoTe31pPE";

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
      const ImageConfiguration(size: Size(40, 40)),
      "assets/icons/truck.png",
    );

    await _getUserLocation();
    _listenToTrucks();
  }

  //--------------------------------------------------
  // GET USER LOCATION
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
// GOOGLE DIRECTIONS POLYLINE (CORRECT v2 SYNTAX)
//--------------------------------------------------
  Future<List<LatLng>> _getPolylineRoute(
      LatLng origin,
      LatLng destination,
      ) async {

    final polylinePoints = PolylinePoints();

    final request = PolylineRequest(
      origin: PointLatLng(origin.latitude, origin.longitude),
      destination: PointLatLng(destination.latitude, destination.longitude),
      mode: TravelMode.driving,
    );

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleAPIKey,
      request: request,
    );

    List<LatLng> routeCoords = [];

    if (result.points.isNotEmpty) {
      for (final point in result.points) {
        routeCoords.add(
          LatLng(point.latitude, point.longitude),
        );
      }
    }

    return routeCoords;
  }

  //--------------------------------------------------
  // MOVE TRUCK ON ROAD
  //--------------------------------------------------

  Future<void> _moveTruckOnRoad(
      String truckId,
      LatLng start,
      LatLng end,
      ) async {

    if (_isAnimating[truckId] == true) return;
    _isAnimating[truckId] = true;

    List<LatLng> route =
    await _getPolylineRoute(start, end);

    for (LatLng pos in route) {

      _markers[truckId] = Marker(
        markerId: MarkerId(truckId),
        position: pos,
        icon: truckIcon ??
            BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: "Truck $truckId",
        ),
      );

      _truckPositions[truckId] = pos;

      if (mounted) setState(() {});

      await Future.delayed(
          const Duration(milliseconds: 350));
    }

    _isAnimating[truckId] = false;
  }

  //--------------------------------------------------
  // NEARBY ALERT
  //--------------------------------------------------

  void _checkNearbyTruck(
      LatLng truckPosition) {

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

          final data =
              event.snapshot.value;
          if (data == null) return;

          final trucks =
          Map<String, dynamic>.from(
              data as Map);

          for (var entry
          in trucks.entries) {

            final id = entry.key;
            final truck =
            Map<String, dynamic>.from(
                entry.value);

            final lat =
            (truck['lat'] as num)
                .toDouble();
            final lng =
            (truck['lng'] as num)
                .toDouble();

            final newPosition =
            LatLng(lat, lng);

            if (!_truckPositions
                .containsKey(id)) {

              _truckPositions[id] =
                  newPosition;

              _markers[id] = Marker(
                markerId:
                MarkerId(id),
                position:
                newPosition,
                icon: truckIcon ??
                    BitmapDescriptor
                        .defaultMarker,
                infoWindow:
                InfoWindow(
                  title:
                  "Truck $id",
                ),
              );

            } else {

              final oldPosition =
              _truckPositions[id]!;

              _moveTruckOnRoad(
                  id,
                  oldPosition,
                  newPosition);
            }

            _checkNearbyTruck(
                newPosition);
          }

          if (mounted)
            setState(() {});
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
              LatLng(6.8480,
                  79.9260),
              zoom: 13,
            ),
            markers:
            _markers.values.toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled:
            true,
            onMapCreated:
                (controller) {
              _mapController
                  .complete(
                  controller);
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
              decoration:
              BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius
                    .circular(18),
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
                MainAxisAlignment
                    .spaceEvenly,
                children: [

                  _actionButton(
                    icon: Icons
                        .calendar_month,
                    label: "Schedule",
                    color:
                    Colors.green,
                    onTap: () {},
                  ),

                  _actionButton(
                    icon:
                    Icons.delete,
                    label:
                    "Dump Points",
                    color:
                    Colors.teal,
                    onTap:
                    _openDumpPoints,
                  ),

                  _actionButton(
                    icon: Icons
                        .warning_amber,
                    label: "Report",
                    color:
                    Colors.orange,
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
            const EdgeInsets.all(
                12),
            decoration:
            BoxDecoration(
              color: color
                  .withOpacity(
                  0.15),
              borderRadius:
              BorderRadius
                  .circular(12),
            ),
            child: Icon(icon,
                color: color),
          ),
          const SizedBox(
              height: 6),
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
