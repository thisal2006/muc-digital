class VehicleType {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VehicleType({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    DateTime? parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return null;
      if (timestamp is Map<String, dynamic>) {
        final seconds = timestamp['_seconds'] as int?;
        if (seconds != null) {
          return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        }
      }
      return null;
    }

    return VehicleType(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      isActive: json['isActive'] ?? true,
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0.0,
      halfDayPrice: (json['halfDayPrice'] as num?)?.toDouble() ?? 0.0,
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
