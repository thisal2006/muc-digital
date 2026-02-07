import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PropertyCalendarScreen extends StatefulWidget {
  const PropertyCalendarScreen({super.key});

  @override
  State<PropertyCalendarScreen> createState() => _PropertyCalendarScreenState();
}

class _PropertyCalendarScreenState extends State<PropertyCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Set<DateTime> _bookedDates = {
    DateTime(2025, 12, 5),
    DateTime(2025, 12, 12),
    DateTime(2025, 12, 20),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Property Booking Calendar"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2026, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // important for month switching
              });
            },
            calendarFormat: CalendarFormat.month,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: const Color(0xFF66BB6A).withAlpha(100), // ← fixed
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            holidayPredicate: (day) {
              return _bookedDates.any((booked) => isSameDay(booked, day));
            },
            calendarBuilders: CalendarBuilders(
              holidayBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Green = Available    •    Red = Booked",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: ElevatedButton(
              onPressed: _selectedDay == null
                  ? null
                  : () {
                final formatted =
                    "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}";
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Selected date: $formatted")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Book Selected Date", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}