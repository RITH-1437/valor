import 'api_product.dart';

class WishlistModel {
  final int id;
  final int productId;
  final ProductModel? product;
  final DateTime? createdAt;

  WishlistModel({
    required this.id,
    required this.productId,
    this.product,
    this.createdAt,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
