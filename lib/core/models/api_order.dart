import 'api_product.dart';

class OrderModel {
  final int id;
  final int userId;
  final String orderNumber;
  final double subtotal;
  final double shippingFee;
  final double total;
  final String status;
  final String statusLabel;
  final String paymentMethod;
  final String shippingAddress;
  final List<OrderItemModel> items;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.status,
    required this.statusLabel,
    required this.paymentMethod,
    required this.shippingAddress,
    this.items = const [],
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingFee: (json['shipping_fee'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      statusLabel: json['status_label'] ?? 'Pending',
      paymentMethod: json['payment_method'] ?? '',
      shippingAddress: json['shipping_address'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

class OrderItemModel {
  final int id;
  final int productId;
  final ProductModel? product;
  final int quantity;
  final double price;
  final double total;

  OrderItemModel({
    required this.id,
    required this.productId,
    this.product,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}
