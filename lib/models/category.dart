class Category {
  final String id;
  final String name;
  // final List<String> products;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] is String ? json['_id'] : '',
      name: json['name'] ?? '',
      // products: List<String>.from(json['products'] ?? []),
    );
  }
}
