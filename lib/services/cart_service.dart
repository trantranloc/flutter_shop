import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart_item.dart';

class CartService {
  static const String baseUrl = 'YOUR_API_ENDPOINT/cart';

  Future<List<CartItem>> fetchCart() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((data) => CartItem.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load cart');
    }
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    await http.put(
      Uri.parse('$baseUrl/$productId'),
      body: jsonEncode({'quantity': newQuantity}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> removeFromCart(String productId) async {
    await http.delete(Uri.parse('$baseUrl/$productId'));
  }
}
