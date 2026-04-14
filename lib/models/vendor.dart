enum VendorStatus {
  pending,
  approved,
  rejected,
}

enum VendorCategory {
  venue,
  catering,
  photography,
  decoration,
  lighting,
  music,
  printing,
  security,
  stage,
  ledWall,
  equipment,
  tent,
  makeup,
}

class Vendor {
  final String id;
  final String name;
  final VendorCategory category;
  final double price;
  final String rating;
  final bool isAvailable;
  bool isShortlisted;
  bool isBooked;
  final String imageUrl;
  final String location;
  VendorStatus status;

  Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    this.isAvailable = true,
    this.isShortlisted = false,
    this.isBooked = false,
    required this.imageUrl,
    required this.location,
    this.status = VendorStatus.approved, // Default to approved for existing ones
  });
}
