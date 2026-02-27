import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CrematoriumBookingScreen extends StatefulWidget {
  const CrematoriumBookingScreen({super.key});

  @override
  State<CrematoriumBookingScreen> createState() => _CrematoriumBookingScreenState();
}

class _CrematoriumBookingScreenState extends State<CrematoriumBookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Set<DateTime> _bookedDates = {
    DateTime(2026, 3, 5),
    DateTime(2026, 3, 10),
    DateTime(2026, 3, 15),
  };

  String? _selectedTimeSlot;  // ← ADD THIS
  final List<String> _availableTimeSlots = [  // ← ADD THIS (example times – later from Firebase)
    'Morning (9:00 AM - 12:00 PM)',
    'Afternoon (1:00 PM - 4:00 PM)',
    'Evening (5:00 PM - 8:00 PM)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crematorium Booking'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select a Date for Crematorium Slot',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!_bookedDates.any((booked) => isSameDay(booked, selectedDay))) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            // ← NEW: Disable booked days completely
            enabledDayPredicate: (day) {
              return !_bookedDates.any((booked) => isSameDay(booked, day));
            },
            // ← NEW: Custom builders to show red/grey for booked
            calendarBuilders: CalendarBuilders(
              disabledBuilder: (context, day, focusedDay) {
                return Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              },
              defaultBuilder: (context, day, focusedDay) {
                if (_bookedDates.any((booked) => isSameDay(booked, day))) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return null;
              },
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue[700],
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue[200],
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Selected: ${_selectedDay!.toLocal().toString().split(' ')[0]} - Available!',
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
            )
          else
            const Padding(
             padding: EdgeInsets.all(16.0),
              child: Text(
                'Tap an available date to select a slot',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Time Slot:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                  ),
                  const SizedBox(height: 16),

                  ..._availableTimeSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTimeSlot = slot;
                    });
                  },
                  child: Card(
                    elevation: isSelected ? 6 : 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isSelected ? Colors.blue[50] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: isSelected ? Colors.blue[100] : Colors.grey[200],
                            child: Icon(
                              _getSlotIcon(slot),
                              color: isSelected ? Colors.blue[800] : Colors.grey[700],
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              slot,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.blue[900] : Colors.black87,
                              ),
                            ),
                          ),
                           if (isSelected)
                              Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 20),

              if (_selectedTimeSlot != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                    Icon(Icons.check_circle_outline, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Selected: $_selectedTimeSlot',
                      style: TextStyle(fontSize: 16, color: Colors.green[800]),
                    ),
                  ],
                ),
              ),
          ],
        ),
     ),
    );

    IconData _getSlotIcon(String slot) {
    if (slot.contains('Morning')) return Icons.wb_sunny;
    if (slot.contains('Afternoon')) return Icons.access_time;
    if (slot.contains('Evening')) return Icons.nights_stay;
    return Icons.schedule;
    }
  }
}
