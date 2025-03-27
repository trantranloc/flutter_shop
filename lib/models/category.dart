class Category {
  final String id;
  final String name;
  final String description;
  final List<String> products;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      products: List<String>.from(json['products'] ?? []),
    );
  }
}
