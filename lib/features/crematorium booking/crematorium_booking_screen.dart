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
        ],
      ),
    );
  }
}