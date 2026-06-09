class ProductModel {
  final String id;
  final String partnerId;
  final String name;
  final String? description;
  final int price;
  final String? imageUrl;
  final bool isAvailable;
  final String? category;

  ProductModel({
    required this.id,
    required this.partnerId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id:          json['id'],
    partnerId:   json['partner_id'],
    name:        json['name'],
    description: json['description'],
    price:       json['price'],
    imageUrl:    json['image_url'],
    isAvailable: json['is_available'] ?? true,
    category:    json['category'],
  );
}