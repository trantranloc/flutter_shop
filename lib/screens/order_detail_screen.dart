import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId; // Order ID passed to the screen

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

      // Call API to fetch order details
      final response = await _apiService.getRequest(
        '/order/${widget.orderId}',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          orderData = response.data; // Data from API
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load order details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order details: $e');
      setState(() {
        _isLoading = false;
        errorMessage = 'Failed to load order details: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade300, Colors.pink.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchOrderDetails,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.pink,
                  backgroundColor: Colors.pinkAccent,
                ),
              )
              : orderData == null
              ? _buildEmptyState()
              : _buildOrderDetails(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.pink.shade200),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'No order data found!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchOrderDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
          // Order Information
          _buildSectionTitle('Order Information', Icons.info),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Order ID', order['_id'] ?? 'N/A'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Status',
                    order['status'] ?? 'N/A',
                    valueColor:
                        order['status'] == 'Success'
                            ? Colors.green.shade600
                            : Colors.orange.shade600,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Payment Method',
                    order['paymentMethod'] == 'cod' ? 'COD' : 'VNPay',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Order Date',
                    order['createdAt']?.substring(0, 10) ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Total',
                    '${totalPrice.toStringAsFixed(0)} ₫',
                    valueStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Products
          _buildSectionTitle('Products', Icons.local_florist),
          _buildOrderItemsList(items),

          // Shipping Address
          _buildSectionTitle('Shipping Address', Icons.location_on),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Name', customer['name'] ?? 'N/A'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Address', address['street'] ?? 'N/A'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'City',
                    '${address['city'] ?? 'N/A'}, ${address['state'] ?? 'N/A'}',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('ZIP Code', address['zip'] ?? 'N/A'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Country', address['country'] ?? 'N/A'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Phone',
                    customer['phone']?.toString() ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Email', customer['email'] ?? 'N/A'),
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var item in items) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item['productId']?['images']?[0] ??
                          'https://via.placeholder.com/80',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.pink.shade100,
                            child: Icon(
                              Icons.local_florist,
                              color: Colors.pink.shade300,
                              size: 40,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Quantity: ${item['quantity'] ?? 0}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${item['price']?.toStringAsFixed(0) ?? 0} ₫/unit',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${item['subtotal']?.toStringAsFixed(0) ?? 0} ₫',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (items.last != item) const Divider(height: 24, thickness: 1),
            ],
            if (items.length > 1) const Divider(height: 32, thickness: 1),
            if (items.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total (${items.length} items):',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${items.fold(0.0, (sum, item) => sum + (item['subtotal'] ?? 0)).toStringAsFixed(0)} ₫',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.pink.shade400, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style:
                valueStyle ??
                TextStyle(
                  fontSize: 14,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
