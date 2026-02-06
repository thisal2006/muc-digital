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

  BitmapDescriptor? activeIcon;
  BitmapDescriptor? closedIcon;


  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadIcons();   // VERY important
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

  void _listenToDumps() {

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

          // VERY IMPORTANT (used in next upgrade)
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
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),


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

              const SizedBox(height: 10),

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

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigation integration comes later
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
