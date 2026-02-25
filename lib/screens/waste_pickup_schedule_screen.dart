import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class WastePickupScheduleScreen extends StatefulWidget {
  const WastePickupScheduleScreen({super.key});

  @override
  State<WastePickupScheduleScreen> createState() => _WastePickupScheduleScreenState();
}

class _WastePickupScheduleScreenState extends State<WastePickupScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('truck1'),
      position: LatLng(6.8480, 79.9265),
      infoWindow: InfoWindow(
        title: 'Garbage Truck 1',
        snippet: 'Current location - Zone A',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ),
    const Marker(
      markerId: MarkerId('truck2'),
      position: LatLng(6.8550, 79.9200),
      infoWindow: InfoWindow(
        title: 'Garbage Truck 2',
        snippet: 'Heading to Zone B',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    ),
    const Marker(
      markerId: MarkerId('truck3'),
      position: LatLng(6.8400, 79.9350),
      infoWindow: InfoWindow(
        title: 'Garbage Truck 3',
        snippet: 'Completed route - Zone C',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ),
  };

  Completer<GoogleMapController> _mapController = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Pickup Schedule'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border(bottom: BorderSide(color: Colors.green[200]!, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_rounded, color: const Color(0xFF1B5E20), size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Pickup Date',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),
            ),

            TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (isSameDay(day, _selectedDay)) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  } else if (day.weekday == DateTime.wednesday) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _selectedDay == null
                    ? 'No date selected'
                    : 'Selected pickup date: ${_selectedDay!.toString().split(' ')[0]}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1B5E20),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[300]!, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(6.8480, 79.9265),
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                  },
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  rotateGesturesEnabled: false,
                  scrollGesturesEnabled: true,
                ),
              ),
            ),

            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: _selectedDay == null
                    ? null
                    : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Pickup scheduled for ${_selectedDay!.toString().split(' ')[0]}',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Confirm Pickup Date'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}