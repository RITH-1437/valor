import 'api_product.dart';

class CartItemModel {
  final int id;
  final int productId;
  final ProductModel? product;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;
  final double totalPrice;
  final DateTime? createdAt;

  CartItemModel({
    required this.id,
    required this.productId,
    this.product,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    required this.totalPrice,
    this.createdAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
      quantity: json['quantity'] ?? 1,
      selectedSize: json['selected_size'],
      selectedColor: json['selected_color'],
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

class CartMeta {
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final int itemCount;

  CartMeta({
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.itemCount,
  });

  factory CartMeta.fromJson(Map<String, dynamic> json) {
    return CartMeta(
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shipping: (json['shipping'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      itemCount: json['item_count'] ?? 0,
    );
  }
}
