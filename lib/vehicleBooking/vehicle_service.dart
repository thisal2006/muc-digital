import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vehicle_models.dart';

class VehicleService {
  final String baseUrl = "http://192.168.1.184:3000/api";

  Future<List<VehicleType>> getVehicleTypes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vehicle-types'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((t) => VehicleType.fromJson(t))
            .toList();
      }
    } catch (e) {
      print('Error fetching vehicle types: $e');
    }
    return [];
  }

  Future<List<Vehicle>> getVehicles({String? typeId}) async {
    try {
      String url = '$baseUrl/vehicles';
      if (typeId != null) url += '?type=$typeId';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List).map((v) => Vehicle.fromJson(v)).toList();
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
    }
    return [];
  }

  Future<Map<String, String>> getAvailability(
    String vehicleId,
    int year,
    int month,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/bookings/availability?vehicleId=$vehicleId&year=$year&month=$month',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> rawList = data['data'] as List<dynamic>? ?? [];
        Map<String, String> availabilityMap = {};

        for (var item in rawList) {
          final dateStr = item['date'] as String;
          final status = item['status'] as String;
          // Use full yyyy-MM-dd as key to avoid month clashes
          availabilityMap[dateStr] = status;
        }
        return availabilityMap;
      }
    } catch (e) {
      print('Error fetching availability: $e');
    }
    return {};
  }

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
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating booking: $e');
    }
    return false;
  }
}
