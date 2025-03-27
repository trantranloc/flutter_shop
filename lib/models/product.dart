class Product {
  final double id;
  final String name;
  final String description;
  final double price;
  final String imageUrl; // Thêm trường này vào

  Product({required this.id,required this.name, required this.description, required this.price, required this.imageUrl});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],

      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}
