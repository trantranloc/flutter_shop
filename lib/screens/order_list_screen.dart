import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List<dynamic>? orders;
  bool _isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserAndOrders();
  }

  Future<void> _fetchUserAndOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy thông tin người dùng từ storage
      final userString = await _storage.read(key: 'user');
      final token = await _storage.read(key: 'accessToken');

      if (userString == null || token == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      userData = json.decode(userString);
      final customerId = userData?['_id']; // Giả định '_id' là customerId

      if (customerId == null) {
        throw Exception('Không tìm thấy ID người dùng');
      }

      // Gọi API để lấy danh sách đơn hàng
      final response = await _apiService.getRequest(
        '/order/customer/$customerId',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          orders =
              response.data is List ? response.data : response.data['orders'];
          _isLoading = false;
        });
      } else {
        throw Exception(
          'Không thể tải danh sách đơn hàng: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() {
        _isLoading = false;
        errorMessage = 'Không thể tải danh sách đơn hàng: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Đơn Hàng'),
        backgroundColor: Colors.pink.shade50,
        elevation: 0,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.pink))
              : orders == null || orders!.isEmpty
              ? Center(child: Text(errorMessage ?? 'Bạn chưa có đơn hàng nào'))
              : _buildOrderList(),
    );
  }

  Widget _buildOrderList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders!.length,
      itemBuilder: (context, index) {
        final order = orders![index]['order'];
        final orderDetail = orders![index]['orderDetail'];
        final totalPrice =
            orderDetail['items'].fold(
              0.0,
              (sum, item) => sum + item['subtotal'],
            ) +
            (order['vat'] ?? 0);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12.0),
            title: Text(
              'Đơn hàng #${order['_id'].substring(0, 8)}...',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text('Trạng thái: ${order['status']}'),
                Text('Tổng tiền: ${totalPrice.toStringAsFixed(0)} ₫'),
                Text('Ngày đặt: ${order['createdAt'].substring(0, 10)}'),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.pink.shade400,
            ),
            onTap: () {
              context.go(
                '/order/${order['_id']}',
              ); // Điều hướng đến chi tiết đơn hàng
            },
          ),
        );
      },
    );
  }
}
