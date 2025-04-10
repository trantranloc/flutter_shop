import 'package:flutter_shop/models/order.dart';
import 'package:flutter_shop/services/api_service.dart';
import 'dart:convert';

class OrderService {
  final ApiService _apiService = ApiService();

  Future<List<Order>> fetchOrdersByCustomerId(String customerId) async {
    try {
      // Sửa lỗi cú pháp trong URL endpoint (thiếu dấu nháy đầu)
      final response = await _apiService.getRequest(
        '/orders?customerId=$customerId',
        headers: {
          'Content-Type': 'application/json',
          // Nếu cần token, uncomment và thêm logic lấy token
          // 'Authorization': 'Bearer ${await _getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.data);
        final List<dynamic> ordersData = jsonResponse['orders'];
        return ordersData.map((order) => Order.fromJson(order)).toList();
      } else {
        throw Exception(
          'Failed to load orders: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      // Thêm stack trace để debug dễ hơn
      throw Exception('Error fetching orders: $e');
    }
  }

  // Phương thức phụ nếu cần lấy token (ví dụ)
  // Future<String> _getToken() async {
  //   // Logic lấy token từ storage hoặc service
  //   return 'your_token_here';
  // }
}
