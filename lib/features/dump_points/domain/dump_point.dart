class DumpPoint {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String address;
  final String status;
  final double capacityTons;
  final double currentLoad;
  final bool supportsRecycling;

  DumpPoint({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
    required this.status,
    required this.capacityTons,
    required this.currentLoad,
    required this.supportsRecycling,
  });

  factory DumpPoint.fromMap(String id, Map data) {
    return DumpPoint(
      id: id,
      name: data['name'],
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      address: data['address'],
      status: data['status'],
      capacityTons: (data['capacity_tons'] as num).toDouble(),
      currentLoad: (data['current_load'] as num).toDouble(),
      supportsRecycling: data['supports_recycling'],
    );
  }
}
