import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  //--------------------------------------------------
  // NOTIFICATIONS
  //--------------------------------------------------

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  DateTime? _lastNotificationTime;

  //--------------------------------------------------
  // INIT
  //--------------------------------------------------

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _requestNotificationPermission();
    await _initNotifications();

    truckIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      "assets/icons/truck.png",
    );

    await _getUserLocation();
    _listenToTrucks();
  }

  //--------------------------------------------------
  // INIT NOTIFICATIONS
  //--------------------------------------------------

  Future<void> _initNotifications() async {

    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidInit);

    await _notifications.initialize(settings);
  }

  Future<void> _showTruckNotification() async {

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'truck_channel',
      'Truck Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      'Garbage Truck Nearby',
      'A garbage truck is within 500m of your location.',
      details,
    );
  }
  Future<void> _requestNotificationPermission() async {

    final status = await Permission.notification.status;

    if (status.isDenied) {
      await Permission.notification.request();
    }

    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
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
  // SMOOTH MOVEMENT
  //--------------------------------------------------

  void _startSmoothMovement(String truckId) {

    _movementTimers[truckId]?.cancel();

    _movementTimers[truckId] =
        Timer.periodic(const Duration(milliseconds: 120), (timer) {

          if (!_markers.containsKey(truckId) ||
              !_targetPositions.containsKey(truckId)) {
            timer.cancel();
            return;
          }

          final current = _markers[truckId]!.position;
          final target = _targetPositions[truckId]!;

          final latDiff = target.latitude - current.latitude;
          final lngDiff = target.longitude - current.longitude;

          final distance = latDiff.abs() + lngDiff.abs();

          if (distance < 0.00001) {
            _markers[truckId] = Marker(
              markerId: MarkerId(truckId),
              position: target,
              icon: truckIcon ?? BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(title: "Truck $truckId"),
            );

            if (mounted) setState(() {});
            return;
          }

          const stepFactor = 0.1;

          final newPos = LatLng(
            current.latitude + (latDiff * stepFactor),
            current.longitude + (lngDiff * stepFactor),
          );

          _markers[truckId] = Marker(
            markerId: MarkerId(truckId),
            position: newPos,
            icon: truckIcon ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: "Truck $truckId"),
          );

          if (mounted) setState(() {});
        });
  }

  //--------------------------------------------------
  // NEARBY ALERT (REAL NOTIFICATION)
  //--------------------------------------------------

  void _checkNearbyTruck(LatLng truckPosition) {

    if (_userPosition == null) return;

    double distance = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      truckPosition.latitude,
      truckPosition.longitude,
    );

    final now = DateTime.now();

    bool canNotify = _lastNotificationTime == null ||
        now.difference(_lastNotificationTime!) >
            const Duration(minutes: 5);

    if (distance < 500 && canNotify) {

      _lastNotificationTime = now;

      _showTruckNotification(); // ✅ REAL NOTIFICATION
    }
  }

  //--------------------------------------------------
  // FIREBASE LISTENER
  //--------------------------------------------------

  void _listenToTrucks() {

    _truckSubscription =
        _truckRef.onValue.listen((event) {

          final data = event.snapshot.value;

          if (data == null || data is! Map) return;

          final trucks = Map<String, dynamic>.from(data);

          for (var entry in trucks.entries) {

            final id = entry.key;

            final truck =
            Map<String, dynamic>.from(entry.value);

            final lat = double.tryParse(
                truck['lat'].toString()) ??
                0.0;

            final lng = double.tryParse(
                truck['lng'].toString()) ??
                0.0;

            final newPosition = LatLng(lat, lng);

            if (!_markers.containsKey(id)) {

              _markers[id] = Marker(
                markerId: MarkerId(id),
                position: newPosition,
                icon: truckIcon ??
                    BitmapDescriptor.defaultMarker,
                infoWindow:
                InfoWindow(title: "Truck $id"),
              );

              _targetPositions[id] = newPosition;

              _startSmoothMovement(id);

            } else {
              _targetPositions[id] = newPosition;
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
        builder: (_) => const DumpPointsScreen(),
      ),
    );
  }

  void _openIllegalDumpReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const IllegalDumpingScreen(),
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
        title: const Text("Live Garbage Truck Tracking"),
      ),
      body: Stack(
        children: [

          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.8480, 79.9260),
              zoom: 14,
            ),
            markers: Set<Marker>.of(_markers.values),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            trafficEnabled: true,
            onMapCreated: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
          ),

          Positioned(
            bottom: 20,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [

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
                    onTap: _openIllegalDumpReport,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}