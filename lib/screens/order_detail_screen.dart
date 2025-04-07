import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId; // ID của đơn hàng được truyền vào

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Map<String, dynamic>? orderData;
  bool _isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      // Gọi API để lấy chi tiết đơn hàng
      final response = await _apiService.getRequest(
        '/order/${widget.orderId}',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          orderData = response.data; // Dữ liệu từ API
          _isLoading = false;
        });
      } else {
        throw Exception(
          'Không thể tải chi tiết đơn hàng: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching order details: $e');
      setState(() {
        _isLoading = false;
        errorMessage = 'Không thể tải chi tiết đơn hàng: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Đơn Hàng'),
        backgroundColor: Colors.pink.shade50,
        elevation: 0,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.pink))
              : orderData == null
              ? Center(child: Text(errorMessage ?? 'Không có dữ liệu đơn hàng'))
              : _buildOrderDetails(),
    );
  }

  Widget _buildOrderDetails() {
    final order = orderData?['order'] ?? {};
    final orderDetail = orderData?['orderDetail'] ?? {};
    final customer = order['customer'] ?? {};
    final address = customer['address'] ?? {};
    final items = orderDetail['items'] as List<dynamic>? ?? [];
    final totalPrice =
        items.fold(0.0, (sum, item) => sum + item['subtotal']) +
        (order['vat'] ?? 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin đơn hàng
          _buildSectionTitle('Thông Tin Đơn Hàng'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mã đơn hàng: ${order['_id']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Trạng thái: ${order['status']}',
                    style: TextStyle(color: Colors.pink),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Phương thức thanh toán: ${order['paymentMethod'] == 'cod' ? 'COD' : 'VNPay'}',
                  ),
                  SizedBox(height: 8),
                  Text('Ngày đặt: ${order['createdAt'].substring(0, 10)}'),
                  SizedBox(height: 8),
                  Text(
                    'Tổng tiền: ${totalPrice.toStringAsFixed(0)} ₫',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Danh sách sản phẩm
          SizedBox(height: 24),
          _buildSectionTitle('Sản Phẩm'),
          _buildOrderItemsList(items),

          // Địa chỉ giao hàng
          SizedBox(height: 24),
          _buildSectionTitle('Địa Chỉ Giao Hàng'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tên: ${customer['name'] ?? ''}'),
                  SizedBox(height: 8),
                  Text('Địa chỉ: ${address['street'] ?? ''}'),
                  SizedBox(height: 8),
                  Text(
                    'Thành phố: ${address['city'] ?? ''}, ${address['state'] ?? ''}',
                  ),
                  SizedBox(height: 8),
                  Text('Mã ZIP: ${address['zip'] ?? ''}'),
                  SizedBox(height: 8),
                  Text('Quốc gia: ${address['country'] ?? ''}'),
                  SizedBox(height: 8),
                  Text('Số điện thoại: ${customer['phone'] ?? ''}'),
                  SizedBox(height: 8),
                  Text('Email: ${customer['email'] ?? ''}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsList(List<dynamic> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['productId']['images'][0] ??
                            'https://via.placeholder.com/60',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.pink.shade100,
                              child: Icon(
                                Icons.image,
                                color: Colors.pink.shade300,
                              ),
                            ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'Không xác định',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Số lượng: ${item['quantity']}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item['subtotal'].toStringAsFixed(0)} ₫',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${item['price'].toStringAsFixed(0)} ₫/cái',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (items.length > 1) Divider(height: 32, thickness: 1),
            if (items.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng (${items.length} sản phẩm):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${items.fold(0.0, (sum, item) => sum + item['subtotal']).toStringAsFixed(0)} ₫',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.pink.shade400,
      ),
    );
  }
}
