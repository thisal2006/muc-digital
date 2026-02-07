class Property {
  final String name;
  final String price;
  final String capacity;
  final String imageUrl;
  final List<String> features;
  final List<String> galleryImages;
  final String description;

  Property({
    required this.name,
    required this.price,
    required this.capacity,
    required this.imageUrl,
    required this.features,
    required this.galleryImages,
    required this.description,
  });
}

// UPDATED DUMMY DATA

final List<Property> dummyProperties = [
  Property(
    name: "Community Hall",
    price: "LKR 5,000",
    capacity: "Up to 100 people",
    imageUrl: "assets/images/hall.jpg",
    features: ["Tables", "Chairs", "Projector","Microphones","Speakers"],
    galleryImages: ["assets/images/hall2.jpg", "assets/images/meeting.jpg"],
    description: "A spacious community hall perfect for seminars, meetings, and small gatherings.",
  ),
  Property(
    name: "Sports Ground",
    price: "LKR 25,000",
    capacity: "Up to 500 people",
    imageUrl: "assets/images/ground.jpg",
    features: ["Grass Turf", "Changing Rooms", "Lights", "Parking"],
    galleryImages: ["assets/images/ground.jpg", "assets/images/auditorium.jpg"],
    description: "Full-sized sports ground suitable for cricket, football, and outdoor events.",
  ),
  Property(
    name: "Auditorium",
    price: "LKR 50,000",
    capacity: "Up to 1000 people",
    imageUrl: "assets/images/auditorium.jpg",
    features: ["Stage", "Sound System","AC", "Lighting", "Parking"],
    galleryImages: [
      "assets/images/auditorium.jpg",
      "assets/images/audi2.jpg",
      "assets/images/audi3.jpg"
    ],
    description: "A massive open-air auditorium designed for concerts, large meetings, and public events.",
  ),
  Property(
    name: "Meeting Room",
    price: "LKR 5,000",
    capacity: "Up to 50 people",
    imageUrl: "assets/images/meeting.jpg",
    features: ["Whiteboard", "AC", "WiFi", "TV Screen"],
    galleryImages: ["assets/images/meeting.jpg"],
    description: "Quiet and professional meeting space for corporate discussions.",
  ),
];