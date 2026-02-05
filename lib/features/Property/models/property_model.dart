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

// ---------------------------------------------------------
// DUMMY DATA (This acts as my "Backend" for now)
// ---------------------------------------------------------
final List<Property> dummyProperties = [
  Property(
    name: "Community Hall",
    price: "LKR 15,000",
    capacity: "Up to 200",
    imageUrl: "https://images.unsplash.com/photo-1517457373958-b7bdd4587205?q=80&w=1469&auto=format&fit=crop", // Placeholder image
  ),
  Property(
    name: "Sports Ground",
    price: "LKR 25,000",
    capacity: "Up to 500",
    imageUrl: "https://images.unsplash.com/photo-1529900748604-07564a03e7a6?q=80&w=1470&auto=format&fit=crop",
  ),
  Property(
    name: "Open Auditorium",
    price: "LKR 50,000",
    capacity: "Up to 1000",
    imageUrl: "https://images.unsplash.com/photo-1475721027767-4d529c145753?q=80&w=1470&auto=format&fit=crop",
  ),
  Property(
    name: "Meeting Room",
    price: "LKR 5,000",
    capacity: "Up to 50",
    imageUrl: "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=1469&auto=format&fit=crop",
  ),
];