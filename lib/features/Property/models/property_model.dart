class Property {
  final String name;
  final String price;
  final String capacity;
  final String imageUrl;
  final List<String> features;
  final List<String> galleryImages;
  final String description;
  final String googleMapsUrl; //Link to Google Maps

  Property({
    required this.name,
    required this.price,
    required this.capacity,
    required this.imageUrl,
    required this.features,
    required this.galleryImages,
    required this.description,
    required this.googleMapsUrl,
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
    //GOOGLE MAPS LINK
    googleMapsUrl: "https://maps.app.goo.gl/pYT2LWJ83Se7g4tBA",
  ),

  Property(
    name: "Nawinna Grounds",
    price: "LKR 18,000",
    capacity: "Up to 500 people",
    imageUrl: "assets/images/ground.jpg",
    features: ["Grass Turf", "Changing Rooms", "Parking"],
    galleryImages: ["assets/images/ground1.png", "assets/images/ground2.png", "assets/images/ground3.png"],
    description: "Full-sized sports ground suitable for cricket, football, and outdoor events.",
    // GOOGLE MAPS LINK
    googleMapsUrl: "https://maps.app.goo.gl/LBhEPvWfpniuJkbW8",
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
    // GOOGLE MAPS LINK
    googleMapsUrl: "https://maps.app.goo.gl/Nx5iwjFaEZ17p2o4A",
  ),
  Property(
    name: "Vavinna Swimming Complex",
    price: "LKR 15,000",
    capacity: "Up to 350 people",
    imageUrl: "assets/images/meeting.jpg",
    features: ["Swimming pool", "Changing rooms", "Washrooms", "Canteen"],
    galleryImages: ["assets/images/poo1/png", "assets/images/poo2.png", "assets/images/poo3.png", "assets/images/poo4.png"],
    description: "Quiet and professional meeting space for corporate discussions.",
    // GOOGLE MAPS LINK
    googleMapsUrl: "https://maps.app.goo.gl/PgEQmDu5xnVYdrHR6",
  ),
];