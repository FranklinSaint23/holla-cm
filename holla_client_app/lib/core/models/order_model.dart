class ProductModel {
  final int price;

  ProductModel({required this.price});
}

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  int get subtotal => product.price * quantity;
}

class OrderModel {
  final String id;
  final String status;
  final int totalAmount;
  final int deliveryFee;
  final String deliveryAddress;
  final String partnerName;
  final String? partnerImage;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final String? deliveryAgentName;
  final double? deliveryLat;
  final double? deliveryLng;
  final int? estimatedDeliveryTime;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.deliveryFee,
    required this.deliveryAddress,
    required this.partnerName,
    this.partnerImage,
    required this.items,
    required this.createdAt,
    this.deliveryAgentName,
    this.deliveryLat,
    this.deliveryLng,
    this.estimatedDeliveryTime,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id:                    json['id'],
    status:                json['status'],
    totalAmount:           json['total_amount'],
    deliveryFee:           json['delivery_fee'],
    deliveryAddress:       json['delivery_address'],
    partnerName:           json['partners']?['business_name'] ?? '',
    partnerImage:          json['partners']?['image_url'],
    items:                 (json['order_items'] as List? ?? [])
        .map((e) => OrderItemModel.fromJson(e))
        .toList(),
    createdAt:             DateTime.parse(json['created_at']),
    deliveryAgentName:     json['delivery_agents']?['profiles']?['name'],
    deliveryLat:           (json['delivery_lat'] as num?)?.toDouble(),
    deliveryLng:           (json['delivery_lng'] as num?)?.toDouble(),
    estimatedDeliveryTime: json['estimated_delivery_time'],
  );
}

class OrderItemModel {
  final String id;
  final String productName;
  final int quantity;
  final int unitPrice;

  OrderItemModel({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  int get subtotal => quantity * unitPrice;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    id:          json['id'],
    productName: json['products']?['name'] ?? '',
    quantity:    json['quantity'],
    unitPrice:   json['unit_price'],
  );
}