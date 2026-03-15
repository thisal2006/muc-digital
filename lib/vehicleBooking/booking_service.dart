import 'dart:convert';
import 'package:http/http.dart' as http;
import 'booking.dart';
import 'vehicle_models.dart';

class BookingService {
  final String baseUrl = "http://192.168.1.184:3000/api";

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
        print(
          'Error creating booking: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error creating booking: $e');
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
