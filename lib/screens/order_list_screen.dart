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
      // Retrieve user information from storage
      final userString = await _storage.read(key: 'user');
      print('User String: $userString');
      final token = await _storage.read(key: 'accessToken');

      if (userString == null || token == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      userData = json.decode(userString);
      final customerId = userData?['_id'];

      if (customerId == null) {
        throw Exception('User ID not found');
      }

      // Call API to fetch orders
      final response = await _apiService.getRequest(
        '/order',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Get order list from response.data['orders']
        List<dynamic> fetchedOrders = response.data['orders'] ?? [];

        // Filter orders by customerId
        orders =
            fetchedOrders
                .where(
                  (orderItem) =>
                      orderItem['order'] != null &&
                      orderItem['order'].containsKey('customerId') &&
                      orderItem['order']['customerId'] == customerId,
                )
                .toList();

        print('Filtered Orders: $orders'); // Log for debugging

        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() {
        _isLoading = false;
        errorMessage = 'Failed to load orders: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
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
            onPressed: _fetchUserAndOrders,
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
              : orders == null || orders!.isEmpty
              ? _buildEmptyState()
              : _buildOrderList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_florist, size: 80, color: Colors.pink.shade200),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'You have no orders yet!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.go('/home'); // Navigate to products page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Shop Now',
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

  Widget _buildOrderList() {
    return RefreshIndicator(
      onRefresh: _fetchUserAndOrders,
      color: Colors.pink,
      child: ListView.builder(
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
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.only(bottom: 16.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                context.go('/order/${order['_id']}');
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order['_id'].substring(0, 8)}...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        _buildStatusChip(order['status']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: ${totalPrice.toStringAsFixed(0)} ₫',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.pink.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${order['createdAt'].substring(0, 10)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_florist,
                          size: 20,
                          color: Colors.pink,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${orderDetail['items'].length} items',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.pink.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'success':
        chipColor = Colors.green.shade100;
        break;
      case 'pending':
        chipColor = Colors.orange.shade100;
        break;
      default:
        chipColor = Colors.grey.shade200;
    }

    return Chip(
      label: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color:
              chipColor == Colors.grey.shade200
                  ? Colors.black54
                  : Colors.black87,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
