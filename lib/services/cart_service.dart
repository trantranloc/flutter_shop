import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_shop/models/product.dart';
import 'package:flutter_shop/models/cart_item.dart';
import 'package:flutter_shop/services/api_service.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  CartService._internal();
  factory CartService() => _instance;

  final List<CartItem> _cartItems = [];

  // Lưu giỏ hàng vào bộ nhớ
  Future<void> _saveCartToStorage() async {
    final cartJson = jsonEncode(
      _cartItems.map((item) => item.toJson()).toList(),
    );

    await _storage.write(key: 'cart', value: cartJson);
    print('Giỏ hàng đã được lưu vào bộ nhớ: $cartJson');
  }

  // Lấy tất cả các sản phẩm trong giỏ hàng
  List<CartItem> getCartItems() {
    return [..._cartItems];
  }

  // Thêm sản phẩm vào giỏ hàng
  void addToCart(Product product, [int quantity = 1]) async {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex] = CartItem(
        id: _cartItems[existingIndex].id,
        name: product.name,
        price: product.price,
        quantity: _cartItems[existingIndex].quantity + quantity,
        images: product.images[0],
        product: product,
      );
    } else {
      _cartItems.add(
        CartItem(
          id: product.id,
          name: product.name,
          price: product.price,
          quantity: quantity,
          images: product.images[0],
          product: product,
        ),
      );
    }
    await _saveCartToStorage();
  }

  // Cập nhật số lượng sản phẩm trong giỏ
  void updateCartItem(String productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      _cartItems[index] = CartItem(
        id: _cartItems[index].id,
        name: _cartItems[index].name,
        price: _cartItems[index].price,
        quantity: quantity,
        images: _cartItems[index].images,
        product: _cartItems[index].product,
      );
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
  }

  // Xóa toàn bộ giỏ hàng
  void clearCart() {
    _cartItems.clear();
  }

  // Tính tổng giỏ hàng
  double getCartTotal() {
    return _cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  // Lấy tổng số lượng sản phẩm trong giỏ hàng
  int getCartItemCount() {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Đặt hàng
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
                  'price': item.price,
                  'name': item.name,
                },
              )
              .toList(),
    };

    try {
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
      throw Exception('Không thể đặt hàng: $e');
    }
  }
}
