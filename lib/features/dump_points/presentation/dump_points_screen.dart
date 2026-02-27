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

class _DumpPointsScreenState extends State<DumpPointsScreen>
    with SingleTickerProviderStateMixin {

  final DumpRepository repo = DumpRepository();

  GoogleMapController? mapController;
  StreamSubscription? dumpSubscription;

  Position? userPosition;

  DumpPoint? nearestDump;
  double nearestDistanceKm = 0;

  static const CameraPosition initialCamera = CameraPosition(
    target: LatLng(6.8480, 79.9260),
    zoom: 13,
  );

  Set<Marker> dumpMarkers = {};

  BitmapDescriptor? activeIcon;
  BitmapDescriptor? closedIcon;

  late AnimationController _cardController;

  //--------------------------------------------------
  // INIT
  //--------------------------------------------------

  @override
  void initState() {
    super.initState();

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _initialize();
  }

  Future<void> _initialize() async {
    await _loadIcons();
    _getUserLocation();
    _listenToDumps();
  }

  //--------------------------------------------------
  // ICONS
  //--------------------------------------------------

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

  //--------------------------------------------------
  // USER LOCATION
  //--------------------------------------------------

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      userPosition =
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  //--------------------------------------------------
  // FIREBASE LISTENER
  //--------------------------------------------------

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

            if (nearestDump != null) {
              _cardController.forward(from: 0);
            }
          }
        });
  }

  //--------------------------------------------------
  // NEAREST DUMP CALCULATION
  //--------------------------------------------------

  void _calculateNearestDump(List<DumpPoint> dumps) {
    if (userPosition == null) {
      return;
    }

    double minDistance = double.infinity;
    DumpPoint? closest;

    for (var dump in dumps) {
      double meters =
      Geolocator.distanceBetween(
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
      nearestDistanceKm =
          minDistance / 1000;
    }
  }

  //--------------------------------------------------
  // NAVIGATION
  //--------------------------------------------------

  Future<void> _navigateToDump(
      DumpPoint dump) async {

    final Uri googleMapsUrl = Uri.parse(
      "google.navigation:q=${dump.lat},${dump.lng}&mode=d",
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  //--------------------------------------------------
  // BOTTOM SHEET
  //--------------------------------------------------

  void _showDumpDetails(DumpPoint dump) {

    double percent =
        dump.currentLoad / dump.capacityTons;

    double distanceKm = 0;

    if (userPosition != null) {
      double meters =
      Geolocator.distanceBetween(
        userPosition!.latitude,
        userPosition!.longitude,
        dump.lat,
        dump.lng,
      );
      distanceKm = meters / 1000;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              Text(
                dump.name,
                style:
                const TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(dump.address),

              const SizedBox(height: 15),

              LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                borderRadius:
                BorderRadius.circular(
                    8),
              ),

              const SizedBox(height: 8),

              Text(
                "${dump.currentLoad} / ${dump.capacityTons} tons",
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "${distanceKm.toStringAsFixed(2)} km away",
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child:
                ElevatedButton(
                  style:
                  ElevatedButton
                      .styleFrom(
                    padding:
                    const EdgeInsets.symmetric(
                        vertical:
                        14),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                          12),
                    ),
                  ),
                  onPressed: () {
                    _navigateToDump(
                        dump);
                  },
                  child:
                  const Text(
                      "Navigate"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //--------------------------------------------------
  // NEAREST CARD
  //--------------------------------------------------

  Widget _nearestDumpCard() {
    return FadeTransition(
      opacity: _cardController,
      child: SlideTransition(
        position:
        Tween<Offset>(
          begin:
          const Offset(0, -0.2),
          end:
          Offset.zero,
        ).animate(_cardController),
        child: Card(
          elevation: 8,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
                16),
          ),
          child: Padding(
            padding:
            const EdgeInsets.all(
                14),
            child: Row(
              children: [

                const Icon(
                  Icons.location_on,
                  color:
                  Colors.green,
                ),

                const SizedBox(
                    width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      const Text(
                        "Nearest Dump",
                        style:
                        TextStyle(
                          fontSize: 12,
                          color: Colors
                              .grey,
                        ),
                      ),
                      Text(
                        nearestDump!
                            .name,
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                      Text(
                        "${nearestDistanceKm.toStringAsFixed(2)} km away",
                      ),
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    _navigateToDump(
                        nearestDump!);
                  },
                  child:
                  const Text(
                      "Go"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------
  // DISPOSE
  //--------------------------------------------------

  @override
  void dispose() {
    dumpSubscription?.cancel();
    _cardController.dispose();
    super.dispose();
  }

  //--------------------------------------------------
  // UI
  //--------------------------------------------------

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
        const Text(
            "Dump Points"),
      ),
      body: Stack(
        children: [

          GoogleMap(
            initialCameraPosition:
            initialCamera,
            markers:
            dumpMarkers,
            myLocationEnabled:
            true,
            myLocationButtonEnabled:
            true,
            onMapCreated:
                (controller) {
              mapController =
                  controller;
            },
          ),

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