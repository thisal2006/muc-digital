import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../dump_points/presentation/dump_points_screen.dart';
import '../illegal_dumping/presentation/illegal_dumping_screen.dart';

class GarbageTrackingScreen extends StatefulWidget {
  const GarbageTrackingScreen({super.key});

  @override
  State<GarbageTrackingScreen> createState() => _GarbageTrackingScreenState();
}

class _GarbageTrackingScreenState extends State<GarbageTrackingScreen> {
  //--------------------------------------------------
  // EXISTING VARIABLES (map/truck tracking)
  //--------------------------------------------------
  final String googleAPIKey = "AIzaSyACUjnMs8ntXloajN-wJx9rr4eoTe31pPE";
  final DatabaseReference _truckRef = FirebaseDatabase.instance.ref('trucks');
  StreamSubscription? _truckSubscription;
  final Completer<GoogleMapController> _mapController = Completer();
  final Map<String, Marker> _markers = {};
  final Map<String, LatLng> _truckPositions = {};
  final Map<String, bool> _isAnimating = {};
  BitmapDescriptor? truckIcon;
  Position? _userPosition;
  bool _nearbyAlertShown = false;

  //--------------------------------------------------
  // CALENDAR & BOOKING VARIABLES
  //--------------------------------------------------
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _timeSlots = {}; // date -> list of slots

  @override
  void initState() {
    super.initState();
    _initialize();
    _loadGarbageScheduleFromFirestore();
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
  // LOAD TIME SLOTS FROM FIRESTORE
  //--------------------------------------------------
  Future<void> _loadGarbageScheduleFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('garbage_schedule').get();

      final Map<DateTime, List<Map<String, dynamic>>> loadedSlots = {};

      for (var doc in snapshot.docs) {
        final dateStr = doc.id; // ID = "yyyy-MM-dd"
        final date = DateFormat('yyyy-MM-dd').parse(dateStr);

        final slotsSnapshot = await doc.reference.collection('time_slots').get();
        final List<Map<String, dynamic>> slots = [];

        for (var slotDoc in slotsSnapshot.docs) {
          final slotData = slotDoc.data();
          if (slotData['available'] == true) {
            slots.add({
              'id': slotDoc.id,
              'time': slotData['time'],
              'price': slotData['price'],
            });
          }
        }

        if (slots.isNotEmpty) {
          loadedSlots[date] = slots;
        }
      }

      if (mounted) {
        setState(() {
          _timeSlots = loadedSlots;
        });
      }
    } catch (e) {
      debugPrint('Error loading garbage schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load schedule: $e')),
        );
      }
    }
  }

  //--------------------------------------------------
  // EXISTING METHODS (truck tracking)
  //--------------------------------------------------
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    _userPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
  }

  Future<List<LatLng>> _getPolylineRoute(LatLng origin, LatLng destination) async {
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
        routeCoords.add(LatLng(point.latitude, point.longitude));
      }
    }
    return routeCoords;
  }

  Future<void> _moveTruckOnRoad(String truckId, LatLng start, LatLng end) async {
    if (_isAnimating[truckId] == true) return;
    _isAnimating[truckId] = true;

    List<LatLng> route = await _getPolylineRoute(start, end);

    for (LatLng pos in route) {
      _markers[truckId] = Marker(
        markerId: MarkerId(truckId),
        position: pos,
        icon: truckIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: "Truck $truckId"),
      );

      _truckPositions[truckId] = pos;

      if (mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 80));
    }

    _isAnimating[truckId] = false;
  }

  void _checkNearbyTruck(LatLng truckPosition) {
    if (_userPosition == null) return;

    double distance = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      truckPosition.latitude,
      truckPosition.longitude,
    );

    if (distance < 500 && !_nearbyAlertShown) {
      _nearbyAlertShown = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚛 Garbage truck is nearby!"),
          backgroundColor: Colors.green,
        ),
      );
    }

    if (distance > 700) {
      _nearbyAlertShown = false;
    }
  }

  void _listenToTrucks() {
    _truckSubscription = _truckRef.onValue.listen((event) {
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
            infoWindow: InfoWindow(title: "Truck $id"),
          );
        } else {
          final oldPosition = _truckPositions[id]!;
          _moveTruckOnRoad(id, oldPosition, newPosition);
        }

        _checkNearbyTruck(newPosition);
      }

      if (mounted) setState(() {});
    });
  }

  void _openDumpPoints() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DumpPointsScreen()),
    );
  }

  void _openIllegalDumpReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IllegalDumpingScreen()),
    );
  }

  //--------------------------------------------------
  // CALENDAR BOTTOM SHEET WITH TIME SLOTS & BOOKING
  //--------------------------------------------------
  void _showScheduleBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter sheetSetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Garbage Collection Schedule',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),

                  // Calendar + time slots + form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TableCalendar(
                            firstDay: DateTime.utc(2025, 1, 1),
                            lastDay: DateTime.utc(2027, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              sheetSetState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            calendarFormat: CalendarFormat.month,
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: const Color(0xFFF57C00).withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: const BoxDecoration(
                                color: Color(0xFF1B5E20),
                                shape: BoxShape.circle,
                              ),
                              markerDecoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              outsideDaysVisible: false,
                            ),
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                            eventLoader: (day) {
                              final dateKey = DateTime(day.year, day.month, day.day);
                              return _timeSlots[dateKey] ?? [];
                            },
                          ),

                          const SizedBox(height: 16),

                          // Time slots for selected day
                          if (_selectedDay != null)
                            _buildTimeSlotsSection(sheetSetState),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Build time slots list + booking form
  Widget _buildTimeSlotsSection(StateSetter sheetSetState) {
    final dateKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final slots = _timeSlots[dateKey] ?? [];

    if (slots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No time slots available on this day',
          style: TextStyle(fontSize: 15, color: Colors.green[900]),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, MMM dd, yyyy').format(_selectedDay!),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Available Time Slots',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        // List of time slots
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(slot['time']),
                trailing: Text(
                  'LKR ${slot['price']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                onTap: () {
                  _showBookingForm(dateKey, slot);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // Show booking form (details + mock payment)
  void _showBookingForm(DateTime dateKey, Map<String, dynamic> slot) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Book Collection Slot'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Date: ${DateFormat('MMM dd, yyyy').format(dateKey)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time: ${slot['time']}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Price: LKR ${slot['price']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Collection Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              final address = addressController.text.trim();

              if (name.isEmpty || address.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and address are required')),
                );
                return;
              }

              try {
                // Show loading
                Navigator.pop(dialogContext);

                // Show payment processing
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Processing payment...'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Mock payment delay
                await Future.delayed(const Duration(seconds: 1));

                // Save booking
                await FirebaseFirestore.instance.collection('bookings').add({
                  'date': DateFormat('yyyy-MM-dd').format(dateKey),
                  'slot': slot['time'],
                  'name': name,
                  'address': address,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                // Mark slot as unavailable
                await FirebaseFirestore.instance
                    .collection('garbage_schedule')
                    .doc(DateFormat('yyyy-MM-dd').format(dateKey))
                    .collection('time_slots')
                    .doc(slot['id'])
                    .update({'available': false});

                // Reload schedule
                await _loadGarbageScheduleFromFirestore();

                // Show success
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Booking confirmed!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error booking slot: $e')),
                  );
                }
              }
            },
            child: const Text('Pay & Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _truckSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Garbage Truck Tracking"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.8480, 79.9260),
              zoom: 13,
            ),
            markers: _markers.values.toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _mapController.complete(controller);
            },
          ),

          // Bottom buttons overlay
          Positioned(
            bottom: 20,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(
                    icon: Icons.calendar_month,
                    label: "Schedule",
                    color: Colors.green,
                    onTap: _showScheduleBottomSheet,
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
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}