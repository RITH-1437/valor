class ProductModel {
  final int id;
  final int categoryId;
  final String? categoryName;
  final String name;
  final String slug;
  final String description;
  final String? shortDescription;
  final double price;
  final double? discountPrice;
  final double effectivePrice;
  final bool hasDiscount;
  final int discountPercent;
  final int stock;
  final String sku;
  final String image;
  final bool isFeatured;
  final bool isTrending;
  final bool isActive;
  final List<ProductImageModel> images;
  final List<ProductSizeModel> sizes;
  final List<ProductColorModel> colors;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.categoryId,
    this.categoryName,
    required this.name,
    required this.slug,
    required this.description,
    this.shortDescription,
    required this.price,
    this.discountPrice,
    required this.effectivePrice,
    required this.hasDiscount,
    required this.discountPercent,
    required this.stock,
    required this.sku,
    required this.image,
    required this.isFeatured,
    required this.isTrending,
    required this.isActive,
    this.images = const [],
    this.sizes = const [],
    this.colors = const [],
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category']?['name'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'],
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discount_price']?.toDouble(),
      effectivePrice: (json['effective_price'] ?? json['price'] ?? 0).toDouble(),
      hasDiscount: json['has_discount'] ?? false,
      discountPercent: json['discount_percent'] ?? 0,
      stock: json['stock'] ?? 0,
      sku: json['sku'] ?? '',
      image: json['image'] ?? '',
      isFeatured: json['is_featured'] ?? false,
      isTrending: json['is_trending'] ?? false,
      isActive: json['is_active'] ?? true,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ProductImageModel.fromJson(e))
              .toList() ??
          [],
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((e) => ProductSizeModel.fromJson(e))
              .toList() ??
          [],
      colors: (json['colors'] as List<dynamic>?)
              ?.map((e) => ProductColorModel.fromJson(e))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  List<String> get imageUrls =>
      images.map((e) => e.image).toList()..insert(0, image);

  List<String> get sizeLabels => sizes.map((e) => e.size).toList();
  List<String> get colorNames => colors.map((e) => e.name).toList();
}

class ProductImageModel {
  final int id;
  final String image;
  final int sortOrder;

  ProductImageModel({
    required this.id,
    required this.image,
    required this.sortOrder,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}

class ProductSizeModel {
  final int id;
  final String size;

  ProductSizeModel({required this.id, required this.size});

  factory ProductSizeModel.fromJson(Map<String, dynamic> json) {
    return ProductSizeModel(
      id: json['id'] ?? 0,
      size: json['size'] ?? '',
    );
  }
}

class ProductColorModel {
  final int id;
  final String name;
  final String hexCode;

  ProductColorModel({
    required this.id,
    required this.name,
    required this.hexCode,
  });

  factory ProductColorModel.fromJson(Map<String, dynamic> json) {
    return ProductColorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      hexCode: json['hex_code'] ?? '#000000',
    );
  }
}
