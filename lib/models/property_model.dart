class Property {
  final String name;
  final String price;
  final String capacity;
  final String imageUrl;

  Property({
    required this.name,
    required this.price,
    required this.capacity,
    required this.imageUrl,
  });
}

// DUMMY DATA (Now using local assets!)

final List<Property> dummyProperties = [
  Property(
    name: "Community Hall",
    price: "LKR 15,000",
    capacity: "Up to 200",
    imageUrl: "assets/images/hall.jpg",
  ),
  Property(
    name: "Sports Ground",
    price: "LKR 25,000",
    capacity: "Up to 500",
    imageUrl: "assets/images/ground.jpg",
  ),
  Property(
    name: "Open Auditorium",
    price: "LKR 50,000",
    capacity: "Up to 1000",
    imageUrl: "assets/images/auditorium.jpg",
  ),
  Property(
    name: "Meeting Room",
    price: "LKR 5,000",
    capacity: "Up to 50",
    imageUrl: "assets/images/meeting.jpg",
  ),
];