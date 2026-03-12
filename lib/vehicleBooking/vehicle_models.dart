class VehicleType {
  final String id;
  final String name;
  final String? description;
  final String? image;

  VehicleType({
    required this.id,
    required this.name,
    this.description,
    this.image,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
    );
  }
}

class Vehicle {
  final String id;
  final String name;
  final double pricePerDay;
  final double halfDayPrice;
  final List<String> includedServices;
  final List<String> images;
  final String typeName;

  Vehicle({
    required this.id,
    required this.name,
    required this.pricePerDay,
    required this.halfDayPrice,
    required this.includedServices,
    required this.images,
    required this.typeName,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'],
      name: json['name'],
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
      halfDayPrice: (json['halfDayPrice'] as num).toDouble(),
      includedServices: List<String>.from(json['includedServices'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      typeName: json['type'] != null ? json['type']['name'] : 'Unknown',
    );
  }
}

enum BookingType { HALF_DAY_AM, HALF_DAY_PM, FULL_DAY, MULTIPLE_DAYS }

extension BookingTypeExtension on BookingType {
  String get value {
    switch (this) {
      case BookingType.HALF_DAY_AM:
        return 'HALF_DAY_AM';
      case BookingType.HALF_DAY_PM:
        return 'HALF_DAY_PM';
      case BookingType.FULL_DAY:
        return 'FULL_DAY';
      case BookingType.MULTIPLE_DAYS:
        return 'MULTIPLE_DAYS';
    }
  }

  String get displayName {
    switch (this) {
      case BookingType.HALF_DAY_AM:
        return 'Half Day (AM)';
      case BookingType.HALF_DAY_PM:
        return 'Half Day (PM)';
      case BookingType.FULL_DAY:
        return 'Full Day (8 hours)';
      case BookingType.MULTIPLE_DAYS:
        return 'Multiple Days';
    }
  }

  String get durationString {
    switch (this) {
      case BookingType.HALF_DAY_AM:
        return '4 hours';
      case BookingType.HALF_DAY_PM:
        return '4 hours';
      case BookingType.FULL_DAY:
        return '8 hours';
      case BookingType.MULTIPLE_DAYS:
        return 'Multi-day';
    }
  }
}
