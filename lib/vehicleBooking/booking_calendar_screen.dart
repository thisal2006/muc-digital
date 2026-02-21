import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'vehicle_models.dart';
import 'vehicle_service.dart';
import 'contact_details_screen.dart';

class BookingCalendarScreen extends StatefulWidget {
  final Vehicle vehicle;

  const BookingCalendarScreen({super.key, required this.vehicle});

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  final VehicleService _vehicleService = VehicleService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.disabled;

  BookingType? _selectedBookingType;
  Map<String, String> _availability = {};

  final Map<String, Color> _statusColors = {
    'AVAILABLE': const Color(0xFFE8F5E9), // Light Green
    'FULLY_BOOKED': const Color(0xFFFFEBEE), // Light Red
    'PARTIALLY_BOOKED_AM': const Color(0xFFE3F2FD), // Light Blue
    'PARTIALLY_BOOKED_PM': const Color(0xFFFFF3E0), // Light Orange
  };

  final Map<String, Color> _statusTextColors = {
    'AVAILABLE': const Color(0xFF2E7D32), // Dark Green
    'FULLY_BOOKED': const Color(0xFFC62828), // Dark Red
    'PARTIALLY_BOOKED_AM': const Color(0xFF1565C0), // Dark Blue
    'PARTIALLY_BOOKED_PM': const Color(0xFFEF6C00), // Dark Orange
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchAvailability();
  }

  Future<void> _fetchAvailability() async {
    final availability = await _vehicleService.getAvailability(
      widget.vehicle.id,
      _focusedDay.year,
      _focusedDay.month,
    );
    setState(() {
      _availability = availability;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;

        // Reset booking type if it's no longer available on the new day
        if (_selectedBookingType != null &&
            !_isSlotAvailable(_selectedBookingType!)) {
          _selectedBookingType = null;
        }
      });
    }
  }

  // Range selection disabled for now as MULTIPLE_DAYS is not in use
  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {}

  Future<void> _handleBooking() async {
    if (_selectedBookingType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a duration')));
      return;
    }

    if (_selectedDay == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    String dateStr = _getDateKey(_selectedDay!);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailsScreen(
          vehicle: widget.vehicle,
          bookingType: _selectedBookingType!,
          startDate: dateStr,
          endDate: dateStr,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Availability Legend',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem(
                'Free',
                const Color(0xFFE8F5E9),
                const Color(0xFF2E7D32),
              ),
              _buildLegendItem(
                'AM Booked',
                const Color(0xFFE3F2FD),
                const Color(0xFF1565C0),
              ),
              _buildLegendItem(
                'PM Booked',
                const Color(0xFFFFF3E0),
                const Color(0xFFEF6C00),
              ),
              _buildLegendItem(
                'Fully Booked',
                const Color(0xFFFFEBEE),
                const Color(0xFFC62828),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  bool _isSlotAvailable(BookingType type) {
    if (_selectedDay == null) return false;
    final status = _availability[_getDateKey(_selectedDay!)] ?? 'AVAILABLE';

    if (status == 'FULLY_BOOKED') return false;

    switch (type) {
      case BookingType.HALF_DAY_AM:
        return status != 'PARTIALLY_BOOKED_AM';
      case BookingType.HALF_DAY_PM:
        return status != 'PARTIALLY_BOOKED_PM';
      case BookingType.FULL_DAY:
        return status == 'AVAILABLE';
      default:
        return true;
    }
  }

  bool _isRangeAvailable() {
    if (_rangeStart == null || _rangeEnd == null) return false;

    DateTime current = _rangeStart!;
    while (current.isBefore(_rangeEnd!) || isSameDay(current, _rangeEnd!)) {
      final status = _availability[_getDateKey(current)] ?? 'AVAILABLE';
      if (status != 'AVAILABLE') return false;
      current = current.add(const Duration(days: 1));
    }
    return true;
  }

  bool _isDayFullyBooked() {
    if (_selectedDay == null) return false;
    final status = _availability[_getDateKey(_selectedDay!)] ?? 'AVAILABLE';
    return status == 'FULLY_BOOKED';
  }

  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Select Date & Time',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A1A),
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1A1A1A),
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAvailability,
        color: const Color(0xFF00897B),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInUp(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    rangeSelectionMode: _rangeSelectionMode,
                    onDaySelected: _onDaySelected,
                    onRangeSelected: _onRangeSelected,
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                      _fetchAvailability();
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final status =
                            _availability[_getDateKey(day)] ?? 'AVAILABLE';
                        final bgColor = _statusColors[status];
                        final textColor = _statusTextColors[status];

                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1B2A),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D1B2A).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        final status =
                            _availability[_getDateKey(day)] ?? 'AVAILABLE';
                        final textColor = _statusTextColors[status];

                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00897B),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                      rangeStartBuilder: (context, day, focusedDay) =>
                          Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1B2A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      rangeEndBuilder: (context, day, focusedDay) => Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1B2A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF0D1B2A),
                        shape: BoxShape.circle,
                      ),
                      rangeStartDecoration: const BoxDecoration(
                        color: Color(0xFF0D1B2A),
                        shape: BoxShape.circle,
                      ),
                      rangeEndDecoration: const BoxDecoration(
                        color: Color(0xFF0D1B2A),
                        shape: BoxShape.circle,
                      ),
                      rangeHighlightColor: const Color(
                        0xFF0D1B2A,
                      ).withOpacity(0.1),
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFF00897B).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(color: Color(0xFF00897B)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildLegend(),
              const SizedBox(height: 32),
              FadeInLeft(
                child: Text(
                  'Duration',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDurationOption(
                BookingType.HALF_DAY_AM,
                'Half Day (AM - 4 hrs)',
                widget.vehicle.halfDayPrice,
                isDisabled: !_isSlotAvailable(BookingType.HALF_DAY_AM),
              ),
              _buildDurationOption(
                BookingType.HALF_DAY_PM,
                'Half Day (PM - 4 hrs)',
                widget.vehicle.halfDayPrice,
                isDisabled: !_isSlotAvailable(BookingType.HALF_DAY_PM),
              ),
              _buildDurationOption(
                BookingType.FULL_DAY,
                'Full Day (8 hours)',
                widget.vehicle.pricePerDay,
                isDisabled: !_isSlotAvailable(BookingType.FULL_DAY),
              ),
              // _buildDurationOption(
              //   BookingType.MULTIPLE_DAYS,
              //   'Multiple Days',
              //   _calculateMultiDayPrice(),
              //   isDisabled:
              //       _rangeStart == null ||
              //       _rangeEnd == null ||
              //       !_isRangeAvailable(),
              // ),
              const SizedBox(height: 48),
              FadeInUp(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isDayFullyBooked() ? null : _handleBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isDayFullyBooked()
                          ? 'Select Another Date'
                          : 'Next: Contact Details',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateMultiDayPrice() {
    if (_rangeStart != null && _rangeEnd != null) {
      final days = _rangeEnd!.difference(_rangeStart!).inDays + 1;
      return days * widget.vehicle.pricePerDay;
    }
    return 0;
  }

  Widget _buildDurationOption(
    BookingType type,
    String title,
    double price, {
    bool isDisabled = false,
  }) {
    final isSelected = _selectedBookingType == type;

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected && !isDisabled
                ? const Color(0xFF00897B)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (!isDisabled)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  setState(() {
                    _selectedBookingType = type;
                    if (type != BookingType.MULTIPLE_DAYS) {
                      _rangeStart = null;
                      _rangeEnd = null;
                      _rangeSelectionMode = RangeSelectionMode.toggledOff;
                      if (_selectedDay == null) _selectedDay = _focusedDay;
                    }
                  });
                },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDisabled
                              ? Colors.grey
                              : isSelected
                              ? const Color(0xFF00897B)
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                      if (isDisabled && type != BookingType.MULTIPLE_DAYS)
                        Text(
                          'Already Booked',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.red[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isDisabled)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'LKR',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00796B),
                        ),
                      ),
                      Text(
                        price > 0 ? NumberFormat('#,###').format(price) : '-',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00796B),
                        ),
                      ),
                    ],
                  ),
                if (isDisabled && type != BookingType.MULTIPLE_DAYS)
                  const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
