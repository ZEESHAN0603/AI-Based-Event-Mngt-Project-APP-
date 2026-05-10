class RecommendationItem {
  final String vendorId;
  final String businessName;
  final String categoryId;
  final String location;
  final double rating;
  final double basePriceMin;
  final double basePriceMax;
  final double score;
  final String reason;

  RecommendationItem({
    required this.vendorId,
    required this.businessName,
    required this.categoryId,
    required this.location,
    required this.rating,
    required this.basePriceMin,
    required this.basePriceMax,
    required this.score,
    required this.reason,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      vendorId: json['vendor_id'] ?? '',
      businessName: json['business_name'] ?? '',
      categoryId: json['category_id'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      basePriceMin: (json['base_price_min'] ?? 0).toDouble(),
      basePriceMax: (json['base_price_max'] ?? 0).toDouble(),
      score: (json['recommendation_score'] ?? 0).toDouble(),
      reason: json['recommendation_reason'] ?? '',
    );
  }
}
