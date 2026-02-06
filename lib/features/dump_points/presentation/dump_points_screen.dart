import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/dump_repository.dart';
import '../domain/dump_point.dart';

class DumpPointsScreen extends StatefulWidget {
  const DumpPointsScreen({super.key});

  @override
  State<DumpPointsScreen> createState() => _DumpPointsScreenState();
}

class _DumpPointsScreenState extends State<DumpPointsScreen> {

  final DumpRepository repo = DumpRepository();

  GoogleMapController? mapController;

  static const CameraPosition initialCamera = CameraPosition(
    target: LatLng(6.8480, 79.9260), // Maharagama
    zoom: 13,
  );

  Set<Marker> dumpMarkers = {};

  //--------------------------------------------------
  // INIT
  //--------------------------------------------------

  @override
  void initState() {
    super.initState();
    _listenToDumps();
  }

  //--------------------------------------------------
  // FIREBASE LISTENER
  //--------------------------------------------------

  void _listenToDumps() {

    repo.watchDumpPoints().listen((List<DumpPoint> dumps) {

      final markers = dumps.map((dump) {

        return Marker(
          markerId: MarkerId(dump.id),
          position: LatLng(dump.lat, dump.lng),

          infoWindow: InfoWindow(
            title: dump.name,
            snippet: dump.address,
          ),
        );

      }).toSet();

      if (mounted) {
        setState(() {
          dumpMarkers = markers;
        });
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
