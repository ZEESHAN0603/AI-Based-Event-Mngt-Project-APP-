enum VendorStatus { pending, approved, rejected }

class Vendor {
  final String id;
  final String userId;
  final String categoryId;
  final String businessName;
  final String description;
  final String location;
  final double basePriceMin;
  final double basePriceMax;
  final double rating;
  final int totalReviews;
  final String gstNumber;
  final String? portfolioUrl;
  final String imageUrl;
  final bool approved;
  bool isShortlisted;
  bool isBooked;

  Vendor({
    required this.id,
    this.userId = '',
    this.categoryId = '',
    required this.businessName,
    this.description = '',
    required this.location,
    this.basePriceMin = 0,
    this.basePriceMax = 0,
    this.rating = 0,
    this.totalReviews = 0,
    this.gstNumber = '',
    this.portfolioUrl,
    this.imageUrl = 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622',
    this.approved = true,
    this.isShortlisted = false,
    this.isBooked = false,
  });

  VendorStatus get status => approved ? VendorStatus.approved : VendorStatus.pending;

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      businessName: json['business_name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      basePriceMin: (json['base_price_min'] ?? 0).toDouble(),
      basePriceMax: (json['base_price_max'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      gstNumber: json['gst_number'] ?? '',
      portfolioUrl: json['portfolio_url'],
      imageUrl: json['image_url'] ?? 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622',
      approved: json['approved'] ?? false,
    );
  }
}
