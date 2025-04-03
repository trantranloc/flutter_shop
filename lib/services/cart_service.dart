import 'package:dio/dio.dart';
import 'package:flutter_shop/models/cart_item.dart';
import 'api_service.dart';

class CartService {
  final ApiService _apiService = ApiService();

  Future<List<CartItem>> fetchCart(String userId) async {
    Response response = await _apiService.getRequest("/cart?userId=$userId");

    if (response.statusCode == 200) {
      List data =
          response.data['data']; // Lấy danh sách sản phẩm trong giỏ hàng
      return data.map((json) => CartItem.fromJson(json)).toList();
    }
    return [];
  }

  // Future<bool> updateCartItemQuantity(String itemId, int quantity) async {
  //   try {
  //     Response response = await _apiService.postRequest(
  //       "/cart/item",
  //       : {'itemId': itemId, 'quantity': quantity},
  //     );
  //     return response.statusCode == 200;
  //   } catch (e) {
  //     print("Lỗi update giỏ hàng: $e");
  //     return false;
  //   }
  // }

  Future<bool> removeCartItem(String itemId) async {
    try {
      Response response = await _apiService.deleteRequest("/cart/item/$itemId");
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi xóa item khỏi giỏ hàng: $e");
      return false;
    }
  }
}
