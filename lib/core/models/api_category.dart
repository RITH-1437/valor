class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? image;
  final String? description;
  final bool isActive;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.description,
    this.isActive = true,
    this.productCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
      productCount: json['product_count'] ?? 0,
    );
  }
}
