import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import '../dump_points/presentation/dump_points_screen.dart';
import '../illegal_dumping/presentation/illegal_dumping_screen.dart';


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

    _listenToTrucks();
  }

  //--------------------------------------------------
  // SMOOTH MOVEMENT
  //--------------------------------------------------

  Future<void> _animateTruck(
      String truckId,
      LatLng oldPos,
      LatLng newPos,
      ) async {

    const steps = 30;
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

        if (mounted) setState(() {});
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

          final oldPosition = _truckPositions[id]!;

          _animateTruck(id, oldPosition, newPosition);

          _truckPositions[id] = newPosition;
        }
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

          //----------------------------------
          // BOTTOM ACTION BUTTONS
          //----------------------------------

          Positioned(
            bottom: 20,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 10),
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

  //--------------------------------------------------
  // BUTTON WIDGET
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
        mainAxisSize: MainAxisSize.min,
        children: [

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
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
