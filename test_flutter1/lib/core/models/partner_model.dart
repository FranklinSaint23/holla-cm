class PartnerModel {
  final String id;
  final String businessName;
  final String businessType;
  final String address;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final bool isVerified;
  final bool isOpen;
  final double rating;
  final int reviewsCount;
  final int? deliveryTime;
  final int? minOrder;
  double? distance;

  PartnerModel({
    required this.id,
    required this.businessName,
    required this.businessType,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.isVerified = false,
    this.isOpen = true,
    this.rating = 0,
    this.reviewsCount = 0,
    this.deliveryTime,
    this.minOrder,
    this.distance,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id:            json['id'],
      businessName:  json['business_name'],
      businessType:  json['business_type'],
      address:       json['address'],
      latitude:      (json['latitude'] as num).toDouble(),
      longitude:     (json['longitude'] as num).toDouble(),
      imageUrl:      json['image_url'],
      isVerified:    json['is_verified'] ?? false,
      isOpen:        json['is_open'] ?? true,
      rating:        (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount:  json['reviews_count'] ?? 0,
      deliveryTime:  json['delivery_time'],
      minOrder:      json['min_order'],
    );
  }
}