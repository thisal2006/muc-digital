class Booking {
  final String id;
  final String vehicle;
  final BookingVehicle? vehicleDetails;
  final String bookingType;
  final String startDate;
  final String endDate;
  final String userName;
  final String userPhone;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? cancelReason;
  final double totalPrice;

  Booking({
    required this.id,
    required this.vehicle,
    this.vehicleDetails,
    required this.bookingType,
    required this.startDate,
    required this.endDate,
    required this.userName,
    required this.userPhone,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.cancelReason,
    required this.totalPrice,
  });

  // Helper getters
  bool get isPending => status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isCancelled => status == 'CANCELLED';

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      vehicle: json['vehicle'] ?? '',
      vehicleDetails: json['vehicleDetails'] != null
          ? BookingVehicle.fromJson(json['vehicleDetails'])
          : null,
      bookingType: json['bookingType'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      userName: json['userName'] ?? '',
      userPhone: json['userPhone'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      cancelReason: json['cancelReason'],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'vehicle': vehicle,
      'vehicleDetails': vehicleDetails?.toJson(),
      'bookingType': bookingType,
      'startDate': startDate,
      'endDate': endDate,
      'userName': userName,
      'userPhone': userPhone,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'cancelReason': cancelReason,
      'totalPrice': totalPrice,
    };
  }
}

class BookingVehicle {
  final String id;
  final String brand;
  final String model;
  final String type;
  final String licensePlate;
  final double pricePerDay;
  final double halfDayPrice;
  final String imageUrl;

  BookingVehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.type,
    required this.licensePlate,
    required this.pricePerDay,
    required this.halfDayPrice,
    required this.imageUrl,
  });

  factory BookingVehicle.fromJson(Map<String, dynamic> json) {
    return BookingVehicle(
      id: json['_id'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      type: json['type'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      pricePerDay: (json['pricePerDay'] ?? 0).toDouble(),
      halfDayPrice: (json['halfDayPrice'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'brand': brand,
      'model': model,
      'type': type,
      'licensePlate': licensePlate,
      'pricePerDay': pricePerDay,
      'halfDayPrice': halfDayPrice,
      'imageUrl': imageUrl,
    };
  }
}