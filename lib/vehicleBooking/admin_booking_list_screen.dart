import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'booking.dart';
import 'booking_service.dart';
import 'booking_widgets.dart';

class AdminBookingListScreen extends StatefulWidget {
  const AdminBookingListScreen({Key? key}) : super(key: key);

  @override
  State<AdminBookingListScreen> createState() => _AdminBookingListScreenState();
}

class _AdminBookingListScreenState extends State<AdminBookingListScreen> {
  final BookingService _bookingService = BookingService();
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String _filter = 'ALL'; // ALL, PENDING, CONFIRMED, CANCELLED

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final bookings = await _bookingService.getAllBookings();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load bookings');
    }
  }

  List<Booking> get _filteredBookings {
    if (_filter == 'ALL') return _bookings;
    return _bookings.where((booking) => booking.status == _filter).toList();
  }

  Future<void> _approveBooking(String bookingId) async {
    try {
      final success = await _bookingService.approveBooking(bookingId);
      if (success) {
        _showSuccessSnackBar('Booking approved successfully');
        _loadBookings(); // Refresh the list
      } else {
        _showErrorSnackBar('Failed to approve booking - slot may already be booked');
      }
    } catch (e) {
      _showErrorSnackBar('Error approving booking: $e');
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final reason = await showCancelReasonDialog(context);
    if (reason != null) {
      try {
        final success = await _bookingService.cancelBooking(bookingId, reason: reason);
        if (success) {
          _showSuccessSnackBar('Booking cancelled successfully');
          _loadBookings(); // Refresh the list
        } else {
          _showErrorSnackBar('Failed to cancel booking');
        }
      } catch (e) {
        _showErrorSnackBar('Error cancelling booking: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Admin - Manage Bookings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A1A),
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1A1A1A)),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildFilterChip('ALL'),
                  const SizedBox(width: 8),
                  _buildFilterChip('PENDING'),
                  const SizedBox(width: 8),
                  _buildFilterChip('CONFIRMED'),
                  const SizedBox(width: 8),
                  _buildFilterChip('CANCELLED'),
                ],
              ),
            ),
          ),
          
          // Bookings List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No ${_filter.toLowerCase()} bookings found',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadBookings,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredBookings.length,
                          itemBuilder: (context, index) {
                            final booking = _filteredBookings[index];
                            return BookingCard(
                              booking: booking,
                              trailing: _buildActionButtons(booking),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _filter == filter;
    final count = filter == 'ALL' 
        ? _bookings.length 
        : _bookings.where((b) => b.status == filter).length;
    
    return FilterChip(
      label: Text(
        '$filter ($count)',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filter = filter);
      },
      selectedColor: const Color(0xFF00897B),
      backgroundColor: Colors.grey[200],
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildActionButtons(Booking booking) {
    if (booking.isPending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.check, size: 16),
            label: Text(
              'Approve',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
            ),
            onPressed: () => _approveBooking(booking.id),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.close, size: 16),
            label: Text(
              'Cancel',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
            ),
            onPressed: () => _cancelBooking(booking.id),
          ),
        ],
      );
    } else if (booking.isConfirmed) {
      return OutlinedButton.icon(
        icon: const Icon(Icons.close, size: 16),
        label: Text(
          'Cancel',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
        ),
        onPressed: () => _cancelBooking(booking.id),
      );
    } else {
      // Cancelled bookings - no actions
      return const SizedBox.shrink();
    }
  }
}