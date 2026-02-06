import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/dump_repository.dart';
import '../domain/dump_point.dart';
import 'package:geolocator/geolocator.dart';

class DumpPointsScreen extends StatefulWidget {
  const DumpPointsScreen({super.key});

  @override
  State<DumpPointsScreen> createState() => _DumpPointsScreenState();
}

class _DumpPointsScreenState extends State<DumpPointsScreen> {

  final DumpRepository repo = DumpRepository();

  GoogleMapController? mapController;
  StreamSubscription? dumpSubscription;

  Position? userPosition;

  static const CameraPosition initialCamera = CameraPosition(
    target: LatLng(6.8480, 79.9260),
    zoom: 13,
  );

  Set<Marker> dumpMarkers = {};

  BitmapDescriptor? activeIcon;
  BitmapDescriptor? closedIcon;



  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {

    await _loadIcons();

    // ⭐ DO NOT BLOCK marker loading if GPS fails
    _getUserLocation();

    _listenToDumps();
  }



  Future<void> _loadIcons() async {

    activeIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      "assets/icons/dump_active.png",
      width: 80,
      height: 80,
    );

    closedIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      "assets/icons/dump_closed.png",
      width: 80,
      height: 80,
    );
  }


  Future<void> _getUserLocation() async {

    try {

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      userPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      // SAFE debug print
      if (userPosition != null) {
        print("USER LAT: ${userPosition!.latitude}");
        print("USER LNG: ${userPosition!.longitude}");
      }

    } catch (e) {
      print("LOCATION ERROR: $e");
    }
  }



  void _listenToDumps() {

    dumpSubscription =
        repo.watchDumpPoints().listen((List<DumpPoint> dumps) {

          final markers = dumps.map((dump) {

            return Marker(
              markerId: MarkerId(dump.id),
              position: LatLng(dump.lat, dump.lng),

              icon: dump.status == "active"
                  ? activeIcon ?? BitmapDescriptor.defaultMarker
                  : closedIcon ?? BitmapDescriptor.defaultMarker,

              infoWindow: InfoWindow(
                title: dump.name,
                snippet: dump.address,
              ),

              onTap: () {
                _showDumpDetails(dump);
              },
            );

          }).toSet();

          if (mounted) {
            setState(() {
              dumpMarkers = markers;
            });
          }
        });
  }



  void _showDumpDetails(DumpPoint dump) {

    double distanceKm = 0;

    if (userPosition != null) {

      double meters = Geolocator.distanceBetween(
        userPosition!.latitude,
        userPosition!.longitude,
        dump.lat,
        dump.lng,
      );

      distanceKm = meters / 1000;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {

        return Container(
          padding: const EdgeInsets.all(20),
          height: 260,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                dump.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(dump.address),

              const SizedBox(height: 12),

              Row(
                children: [

                  Icon(
                    dump.status == "active"
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: dump.status == "active"
                        ? Colors.green
                        : Colors.red,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    dump.status.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: dump.status == "active"
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [

                  const Icon(Icons.route, color: Colors.blue),
                  const SizedBox(width: 6),

                  Text(
                    "${distanceKm.toStringAsFixed(2)} km away",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Navigate"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  void dispose() {
    dumpSubscription?.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dump Points"),
      ),

      body: GoogleMap(
        initialCameraPosition: initialCamera,
        markers: dumpMarkers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,

        onMapCreated: (controller) {
          mapController = controller;
        },
      ),
    );
  }
}
