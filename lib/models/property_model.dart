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
    features: ["Fans", "Sound System", "Chairs", "Projector"],
    galleryImages: ["assets/images/hall2.png", "assets/images/hall3.png"],
    description: "A spacious community hall perfect for meetings, community work, and small gatherings.",
    // LINK:
    googleMapsUrl: "https://maps.app.goo.gl/C6RXs6NehAu19A787?g_st=ic",
    contactNumber: "+94 112 849 144",
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
    googleMapsUrl: "https://maps.app.goo.gl/ZEM5s8sJfHcjnYeX8?g_st=ic",
    contactNumber: "0112 850 265",
  ),

  Property(
    name: "Auditorium",
    price: "LKR 50,000",
    capacity: "Up to 1000 people",
    imageUrl: "assets/images/auditorium.jpg",
    features: ["Stage", "AC", "Sound System", "Lighting", "Parking"],
    galleryImages: [
      "assets/images/auditorium.jpg",
      "assets/images/audi2.jpg",
      "assets/images/audi3.jpg"
    ],
    description: "A massive air conditioned auditorium designed for concerts, large meetings, and public events.",
    // LINK:
    googleMapsUrl: "https://maps.app.goo.gl/NWp2toSUb2XvM3cv5?g_st=ic",
    contactNumber: "011 247 7840",
  ),

  Property(
    name: "Navinna Swimming Complex",
    price: "LKR 15,000",
    capacity: "Up to 350 people",
    imageUrl: "assets/images/poo1.png",
    features: ["Swimming pool", "Changing rooms", "Washrooms", "Canteen"],
    galleryImages: ["assets/images/poo1.png", "assets/images/poo2.png", "assets/images/poo3.png", "assets/images/poo4.png"],
    description: "A swimming complex suitable for swimming practices, meets, and etc.",
    // LINK:
    googleMapsUrl: "https://maps.app.goo.gl/hjou8tzBf7EVvkfa9?g_st=ic",
    contactNumber: "077 087 3798",
  ),
];

