import 'category.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final List<String> images;
  final String description;
  final int stock;
  final int quantity;
  final Category category;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.images,
    required this.description,
    required this.stock,
    required this.quantity,
    required this.category,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      description: json['description'],
      stock: json['stock'],
      quantity: json['quantity'],
      category: Category.fromJson(json['category']),
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}
