import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'booking.dart';

/// Status badge widget for bookings
Widget statusBadge(String status) {
  Color backgroundColor;
  Color textColor;
  String displayText;

  switch (status.toUpperCase()) {
    case 'PENDING':
      backgroundColor = const Color(0xFFFFF3E0); // Light Orange
      textColor = const Color(0xFFEF6C00); // Dark Orange
      displayText = 'PENDING';
      break;
    case 'CONFIRMED':
      backgroundColor = const Color(0xFFE8F5E9); // Light Green
      textColor = const Color(0xFF2E7D32); // Dark Green
      displayText = 'CONFIRMED';
      break;
    case 'CANCELLED':
      backgroundColor = const Color(0xFFFFEBEE); // Light Red
      textColor = const Color(0xFFC62828); // Dark Red
      displayText = 'CANCELLED';
      break;
    default:
      backgroundColor = const Color(0xFFE0E0E0); // Light Grey
      textColor = const Color(0xFF424242); // Dark Grey
      displayText = status.toUpperCase();
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: textColor.withOpacity(0.3)),
    ),
    child: Text(
      displayText,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    ),
  );
}

/// Booking card widget for lists
class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;
  final Widget? trailing;

  const BookingCard({
    Key? key,
    required this.booking,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.vehicleDetails?.brand ?? 'Vehicle',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          booking.vehicleDetails?.model ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  statusBadge(booking.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    booking.userName,
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    booking.userPhone,
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${booking.startDate} - ${booking.endDate}',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    booking.bookingType.replaceAll('_', ' '),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
              if (trailing != null) ...[
                const SizedBox(height: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Cancel reason dialog
Future<String?> showCancelReasonDialog(BuildContext context) async {
  final TextEditingController reasonController = TextEditingController();
  
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Cancel Booking',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Please provide a reason for cancellation:',
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Enter cancellation reason...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final reason = reasonController.text.trim();
            if (reason.isNotEmpty) {
              Navigator.of(context).pop(reason);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Confirm Cancel',
            style: GoogleFonts.poppins(),
          ),
        ),
      ],
    ),
  );
}