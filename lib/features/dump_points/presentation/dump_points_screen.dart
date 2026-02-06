import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DumpPointsScreen extends StatefulWidget {
  const DumpPointsScreen({super.key});

  @override
  State<DumpPointsScreen> createState() => _DumpPointsScreenState();
}

class _DumpPointsScreenState extends State<DumpPointsScreen> {

  GoogleMapController? mapController;

  static const CameraPosition initialCamera = CameraPosition(
    target: LatLng(6.8480, 79.9260), // Maharagama
    zoom: 13,
  );

  final Set<Marker> dumpMarkers = {};

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
      ),
    );
  }
}
