class Property {
  final String name;
  final String price;
  final String capacity;
  final String imageUrl;
  final List<String> features;
  final List<String> galleryImages;
  final String description;
  final String googleMapsUrl;
  final String contactNumber;

  Property({
    required this.name,
    required this.price,
    required this.capacity,
    required this.imageUrl,
    required this.features,
    required this.galleryImages,
    required this.description,
    required this.googleMapsUrl,
    required this.contactNumber,
  });
}

// REAL DATA

final List<Property> dummyProperties = [
  Property(
    name: "Suhada Community Center",
    price: "LKR 15,000",
    capacity: "Up to 200 people",
    imageUrl: "assets/images/hall.jpg",
    features: ["AC", "Sound System", "Chairs", "Projector"],
    galleryImages: ["assets/images/hall2.png", "assets/images/hall3.png"],
    description: "A spacious community hall perfect for weddings, parties, and small gatherings.",
    // LINK:
    googleMapsUrl: "https://www.google.com/maps/search/?api=1&query=Colombo+Community+Center",
    contactNumber: "071 123 4567",
  ),

  Property(
    name: "Nawinna Grounds",
    price: "LKR 18,000",
    capacity: "Up to 500 people",
    imageUrl: "assets/images/ground.jpg",
    features: ["Grass Turf", "Changing Rooms", "Parking"],
    galleryImages: ["assets/images/ground1.png", "assets/images/ground2.png", "assets/images/ground3.png"],
    description: "Full-sized sports ground suitable for cricket, football, and outdoor events.",
    //LINK:
    googleMapsUrl: "https://www.google.com/maps/search/?api=1&query=Nawinna+Grounds",
    contactNumber: "077 987 6543",
  ),

  Property(
    name: "Auditorium",
    price: "LKR 50,000",
    capacity: "Up to 1000 people",
    imageUrl: "assets/images/auditorium.jpg",
    features: ["Stage", "Sound System", "Lighting", "Parking"],
    galleryImages: [
      "assets/images/auditorium.jpg",
      "assets/images/audi2.jpg",
      "assets/images/audi3.jpg"
    ],
    description: "A massive air conditioned auditorium designed for concerts, large meetings, and public events.",
    // LINK:
    googleMapsUrl: "https://www.google.com/maps/search/?api=1&query=Colombo+Auditorium",
    contactNumber: "011 234 5678",
  ),

  Property(
    name: "Navinna Swimming Complex",
    price: "LKR 15,000",
    capacity: "Up to 350 people",
    imageUrl: "assets/images/meetingroom.jpg",
    features: ["Swimming pool", "Changing rooms", "Washrooms", "Canteen"],
    galleryImages: ["assets/images/poo1.png", "assets/images/poo2.png", "assets/images/poo3.png", "assets/images/poo4.png"],
    description: "Quiet and professional meeting space for corporate discussions.",
    // LINK:
    googleMapsUrl: "https://www.google.com/maps/search/?api=1&query=Nawinna+Swimming+Pool",
    contactNumber: "076 555 0101",
  ),
];
