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
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              // Later: show available slots or proceed to form
            },
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
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Selected: ${_selectedDay!.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }
}