import 'package:flutter_shop/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  final ApiService _apiService = ApiService();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final List<CartItem> _cartItems = [];

  // Get all cart items
  List<CartItem> getCartItems() {
    return [..._cartItems];
  }

  // Add product to cart
  void addToCart(Product product, [int quantity = 1]) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex] = CartItem(
        product: product,
        quantity: _cartItems[existingIndex].quantity + quantity,
      );
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
  }

  // Update quantity of a cart item
  void updateCartItem(String productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      _cartItems[index] = CartItem(
        product: _cartItems[index].product,
        quantity: quantity,
      );
    }
  }

  // Remove product from cart
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
  }

  // Clear entire cart
  void clearCart() {
    _cartItems.clear();
  }

  // Get cart total
  double getCartTotal() {
    return _cartItems.fold(
      0,
      (sum, item) => sum + item.product.price * item.quantity,
    );
  }

  // Get cart item count
  int getCartItemCount() {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Submit order (for COD)
  Future<void> submitOrder({
    required Map<String, dynamic> user,
    required Map<String, dynamic> billingData,
    required String paymentMethod,
    required String notes,
  }) async {
    final orderData = {
      'userId': user['_id'],
      'userDetails': billingData,
      'orderDetails': {
        'totalPrice': getCartTotal(),
        'shippingAddress': billingData,
        'notes': notes,
        'paymentMethod': paymentMethod,
      },
      'items':
          _cartItems
              .map(
                (item) => {
                  'productId': item.product.id,
                  'quantity': item.quantity,
                  'price': item.product.price,
                  'name': item.product.name,
                },
              )
              .toList(),
    };

    try {
      print("Order data: $orderData");

      final response = await _apiService.postRequest(
        "/order",
        jsonEncode(orderData),
        headers: {
          'Authorization': 'Bearer ${user['accessToken']}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Đặt hàng thất bại: ${response.statusCode}');
      }
      clearCart(); // Xóa giỏ hàng sau khi đặt hàng thành công
    } catch (e) {
      print("Error submitting order: $e");
      throw Exception('Không thể đặt hàng: $e');
    }
  }

  // Initiate VNPay payment
  Future<String> initiateVnpayPayment() async {
    final response = await http.post(
      Uri.parse('http://localhost:3002/api/payment/create-payment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': getCartTotal(),
        'orderId': 'ORDER${DateTime.now().millisecondsSinceEpoch}',
        'orderDescription':
            'Payment for order #${DateTime.now().millisecondsSinceEpoch}',
        'bankCode': 'NCB',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['paymentUrl'];
    } else {
      throw Exception(
        'Failed to initiate VNPay payment: ${response.statusCode}',
      );
    }
  }
}

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});
}
