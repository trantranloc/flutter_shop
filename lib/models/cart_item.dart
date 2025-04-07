import 'package:flutter_shop/models/product.dart';

class CartItem {
  final String id; // Mã giỏ hàng
  final String name; // Tên sản phẩm
  final double price; // Giá sản phẩm
  final int quantity; // Số lượng sản phẩm trong giỏ hàng
  final String images; // Đường dẫn hình ảnh sản phẩm
  final Product product; // Thông tin chi tiết về sản phẩm

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.images,
    required this.product,
  });

  // Convert CartItem to JSON for saving to storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'images': images,
      'product': product.toJson(), // Product converted to JSON
    };
  }

  // Convert JSON to CartItem
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      images: json['images'] ?? 'https://via.placeholder.com/150',
      product: Product.fromJson(json['product']), // Convert product from JSON
    );
  }
}
