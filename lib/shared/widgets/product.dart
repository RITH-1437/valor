class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final String brand;
  final double rating;
  final List<String> sizes;
  final List<String> colors;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.brand,
    required this.rating,
    required this.sizes,
    required this.colors,
  });
}