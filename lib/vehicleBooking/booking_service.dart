import 'dart:convert';
import 'package:http/http.dart' as http;
import 'booking.dart';
import 'vehicle_models.dart';

class BookingService {
  final String baseUrl = "http://10.169.126.246:3000/api";

  /// Creates a new booking with PENDING status
  Future<bool> createBooking({
    required String vehicleId,
    required BookingType bookingType,
    required String startDate,
    required String endDate,
    required String userName,
    required String userPhone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'vehicle': vehicleId,
          'bookingType': bookingType.value,
          'startDate': startDate,
          'endDate': endDate,
          'userName': userName,
          'userPhone': userPhone,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Error creating booking: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    }
  }

  /// Gets all bookings (for admin view)
  Future<List<Booking>> getAllBookings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bookings'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> bookingsJson = data['data'] ?? [];
        
        return bookingsJson.map((json) => Booking.fromJson(json)).toList();
      } else {
        print('Error fetching bookings: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  /// Approves a pending booking (Admin only)
  Future<bool> approveBooking(String bookingId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$bookingId/approve'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        // Conflict - slot already booked
        print('Booking conflict: Slot already booked by another booking');
        return false;
      } else {
        print('Error approving booking: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error approving booking: $e');
      return false;
    }
  }

  /// Cancels a booking with optional reason
  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$bookingId/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          if (reason != null) 'cancelReason': reason,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error cancelling booking: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error cancelling booking: $e');
      return false;
    }
  }

  /// Gets user's bookings  
  Future<List<Booking>> getUserBookings(String userPhone) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings?userPhone=$userPhone'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> bookingsJson = data['data'] ?? [];
        
        return bookingsJson.map((json) => Booking.fromJson(json)).toList();
      } else {
        print('Error fetching user bookings: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching user bookings: $e');
      return [];
    }
  }
}