import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/dump_repository.dart';
import '../domain/dump_point.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';


class DumpPointsScreen extends StatefulWidget {
  const DumpPointsScreen({super.key});

  @override
  State<DumpPointsScreen> createState() => _DumpPointsScreenState();
}

class _DumpPointsScreenState extends State<DumpPointsScreen> {
  Future<void> _navigateToDump(DumpPoint dump) async {

    final Uri googleMapsUrl = Uri.parse(
      "google.navigation:q=${dump.lat},${dump.lng}&mode=d",
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch Google Maps';
    }
  }
  DumpPoint? nearestDump;
  double nearestDistanceKm = 0;

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
          _calculateNearestDump(dumps);


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
    Color capacityColor = Colors.green;

    double percent = dump.currentLoad / dump.capacityTons;

    if (percent > 0.8) {
      capacityColor = Colors.red;
    } else if (percent > 0.5) {
      capacityColor = Colors.orange;
    }


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
              const SizedBox(height: 12),

              Row(
                children: [

                  Icon(
                    Icons.storage,
                    color: capacityColor,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    "Capacity: ${dump.currentLoad} / ${dump.capacityTons} tons",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: capacityColor,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToDump(dump);
                  },

                  child: const Text("Navigate"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _calculateNearestDump(List<DumpPoint> dumps) {

    if (userPosition == null) return;

    double minDistance = double.infinity;
    DumpPoint? closest;

    for (var dump in dumps) {

      double meters = Geolocator.distanceBetween(
        userPosition!.latitude,
        userPosition!.longitude,
        dump.lat,
        dump.lng,
      );

      if (meters < minDistance) {
        minDistance = meters;
        closest = dump;
      }
    }

    if (closest != null) {
      nearestDump = closest;
      nearestDistanceKm = minDistance / 1000;
    }
  }

  Widget _nearestDumpCard() {

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Row(
          children: [

            //--------------------------------
            // ICON
            //--------------------------------

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.green,
              ),
            ),

            const SizedBox(width: 12),

            //--------------------------------
            // TEXT
            //--------------------------------

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Nearest Dump",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),

                  Text(
                    nearestDump!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "${nearestDistanceKm.toStringAsFixed(2)} km away",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            //--------------------------------
            // NAV BUTTON
            //--------------------------------

            ElevatedButton(
              onPressed: () {
                _navigateToDump(nearestDump!);
              },
              child: const Text("Go"),
            )
          ],
        ),
      ),
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

      body: Stack(
        children: [

          GoogleMap(
            initialCameraPosition: initialCamera,
            markers: dumpMarkers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),

          //-----------------------------------
          // NEAREST DUMP CARD
          //-----------------------------------

          if (nearestDump != null)
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: _nearestDumpCard(),
            ),
        ],
      ),

    );
  }
}
